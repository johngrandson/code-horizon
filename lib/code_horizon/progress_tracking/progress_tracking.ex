defmodule CodeHorizon.ProgressTracking do
  @moduledoc """
  The ProgressTracking context handles all operations related to tracking
  student progress through courses, lessons and assessments.
  """

  import Ecto.Query, warn: false

  alias CodeHorizon.Enrollments
  alias CodeHorizon.EventBus
  alias CodeHorizon.Lessons
  alias CodeHorizon.ProgressTracking.Events
  alias CodeHorizon.ProgressTracking.Progress
  alias CodeHorizon.Repo

  # --- Basic CRUD Operations ---

  @doc """
  Returns the list of progress records.
  """
  def list_progress, do: Repo.all(Progress)

  @doc """
  Gets a single progress record by ID.
  """
  def get_progress!(id), do: Repo.get!(Progress, id)

  @doc """
  Gets a progress record by enrollment and lesson IDs.
  """
  def get_progress_by_enrollment_and_lesson(enrollment_id, lesson_id) do
    Repo.get_by(Progress, enrollment_id: enrollment_id, lesson_id: lesson_id)
  end

  @doc """
  Returns a changeset for tracking progress changes.
  """
  def change_progress(%Progress{} = progress, attrs \\ %{}), do: Progress.changeset(progress, attrs)

  @doc """
  Creates a progress record and broadcasts a creation event.

  Returns `{:ok, progress}` or `{:error, changeset}`

  ## Examples

      iex> ProgressTracking.create_progress(%{
        enrollment_id: 1,
        lesson_id: 1,
        completion_status: :in_progress,
        percent_complete: 100,
        last_accessed_at: DateTime.utc_now(),
        completion_date: DateTime.utc_now()
      })
      {:ok, %Progress{}}

      iex> create_progress(%{field: bad_value})
      {:error, %Ecto.Changeset{}}
  """
  def create_progress(attrs \\ %{}) do
    %Progress{}
    |> Progress.changeset(attrs)
    |> Repo.insert()
    |> EventBus.broadcast_on_success(&Events.broadcast_created/1)
  end

  @doc """
  Updates a progress record and broadcasts relevant events.
  """
  def update_progress(%Progress{} = progress, attrs) do
    previous_status = progress.completion_status
    previous_percent = progress.percent_complete

    result =
      progress
      |> Progress.changeset(attrs)
      |> Repo.update()

    case result do
      {:ok, updated_progress} = success ->
        # Broadcast standard update event
        Events.broadcast_updated(updated_progress)

        # Detect completion state transition
        # Note: Using atoms for Ecto.Enum values
        if previous_status != :completed && updated_progress.completion_status == :completed do
          Events.broadcast_lesson_completed(updated_progress)
          check_and_update_enrollment_progress(updated_progress.enrollment_id)
        end

        # Check for milestone reached
        check_for_milestone(
          updated_progress.enrollment_id,
          previous_percent,
          updated_progress.percent_complete
        )

        success

      error ->
        error
    end
  end

  @doc """
  Deletes a progress record.
  """
  def delete_progress(%Progress{} = progress), do: Repo.delete(progress)

  # --- Student Progress Management ---

  @doc """
  Creates initial progress records for all lessons in a course when a student enrolls.
  """
  def initialize_progress_for_enrollment(enrollment_id) do
    # Get the enrollment with course
    enrollment =
      enrollment_id
      |> Enrollments.get_enrollment!()
      |> Repo.preload(:course)

    # Get all lessons for the course
    lessons = Lessons.list_lessons_by_course(enrollment.course_id)

    # Create progress records for each lesson
    Enum.map(lessons, fn lesson ->
      create_progress(%{
        enrollment_id: enrollment_id,
        lesson_id: lesson.id,
        completion_status: :not_started,
        percent_complete: 0,
        last_accessed_at: nil,
        completion_date: nil
      })
    end)
  end

  @doc """
  Records that a student has started working on a lesson.
  """
  def start_lesson(enrollment_id, lesson_id) do
    case get_progress_by_enrollment_and_lesson(enrollment_id, lesson_id) do
      nil ->
        create_progress(%{
          enrollment_id: enrollment_id,
          lesson_id: lesson_id,
          # Using atom instead of string
          completion_status: :in_progress,
          percent_complete: 0,
          last_accessed_at: DateTime.utc_now()
        })

      progress ->
        status_update =
          if progress.completion_status == :not_started do
            # Using atom instead of string
            %{completion_status: :in_progress}
          else
            %{}
          end

        update_progress(progress, Map.put(status_update, :last_accessed_at, DateTime.utc_now()))
    end
  end

  @doc """
  Marks a lesson as completed for a student.
  """
  def complete_lesson(enrollment_id, lesson_id) do
    case get_progress_by_enrollment_and_lesson(enrollment_id, lesson_id) do
      nil ->
        create_progress(%{
          enrollment_id: enrollment_id,
          lesson_id: lesson_id,
          completion_status: :completed,
          percent_complete: 100,
          last_accessed_at: DateTime.utc_now(),
          completion_date: DateTime.utc_now()
        })

      progress ->
        update_progress(progress, %{
          completion_status: :completed,
          percent_complete: 100,
          last_accessed_at: DateTime.utc_now(),
          completion_date: DateTime.utc_now()
        })
    end
  end

  # --- Progress Analytics and Reporting ---

  @doc """
  Calculates the overall progress percentage for an enrollment.
  """
  def calculate_enrollment_progress(enrollment_id) do
    # Using fragment with atom value for the enum comparison
    # Define the atom for interpolation
    completion_status = :completed

    query =
      from p in Progress,
        where: p.enrollment_id == ^enrollment_id,
        select: %{
          total: count(p.id),
          completed: sum(fragment("CASE WHEN ? = ? THEN 1 ELSE 0 END", p.completion_status, ^completion_status))
        }

    result = Repo.one(query)

    case result do
      %{total: total, completed: completed} when total > 0 ->
        trunc(completed / total * 100)

      _ ->
        0
    end
  end

  @doc """
  Gets the next incomplete lesson for an enrollment.
  """
  def get_next_incomplete_lesson(enrollment_id) do
    # Get the course for this enrollment
    course_id =
      Repo.one(from(e in CodeHorizon.Enrollments.Enrollment, where: e.id == ^enrollment_id, select: e.course_id))

    if course_id do
      # Get lessons ordered by sequence
      lessons =
        Repo.all(from(l in CodeHorizon.Lessons.Lesson, where: l.course_id == ^course_id, order_by: [asc: l.order]))

      # Define completion status as atom for proper comparison
      completion_status = :completed

      # Get completed lesson IDs
      completed_lesson_ids =
        from(p in Progress,
          where: p.enrollment_id == ^enrollment_id and p.completion_status == ^completion_status,
          select: p.lesson_id
        )
        |> Repo.all()
        |> MapSet.new()

      # Find first lesson not completed
      Enum.find(lessons, fn lesson -> not MapSet.member?(completed_lesson_ids, lesson.id) end)
    end
  end

  @doc """
  Gets recent activity records for a student.

  ## Options
    - `:limit` - The maximum number of activities to return

  ## Returns
    A list of activity records

  ## Examples
    iex> get_recent_activity("student_id")
    [%Activity{type: "lesson_completion", timestamp: ~N[2023-01-01 00:00:00]}, ...]
  """
  def get_recent_activity(student_id, opts \\ []) do
    limit = Keyword.get(opts, :limit, 10)

    # Create the combined activity result
    lesson_completions = get_recent_lesson_completions(student_id, limit)
    assessment_completions = get_recent_assessment_completions(student_id, limit)
    enrollments = get_recent_enrollments(student_id, limit)

    # Combine and sort all activities
    (lesson_completions ++ assessment_completions ++ enrollments)
    |> Enum.sort_by(fn activity -> activity.timestamp end, :desc)
    |> Enum.take(limit)
    |> Enum.map(fn activity ->
      # Create a truly unique ID using multiple attributes
      timestamp_str = NaiveDateTime.to_string(activity.timestamp)
      unique_suffix = :rand.uniform(1000)

      Map.put(activity, :id, "#{activity.type}-#{unique_suffix}-#{timestamp_str}")
    end)
  end

  # --- Private Helper Functions ---

  # Extract recent lesson completions for cleaner code organization
  defp get_recent_lesson_completions(student_id, limit) do
    # Using atom for proper Ecto.Enum comparison
    completion_status = :completed

    Repo.all(
      from(p in Progress,
        join: e in CodeHorizon.Enrollments.Enrollment,
        on: p.enrollment_id == e.id,
        join: l in CodeHorizon.Lessons.Lesson,
        on: p.lesson_id == l.id,
        join: c in CodeHorizon.Courses.Course,
        on: l.course_id == c.id,
        where: e.student_id == ^student_id and p.completion_status == ^completion_status,
        order_by: [desc: p.updated_at],
        select: %{
          type: :lesson_completed,
          lesson_id: l.id,
          lesson_title: l.title,
          course_id: c.id,
          course_title: c.title,
          timestamp: p.updated_at
        },
        limit: ^limit
      )
    )
  end

  # Extract recent assessment completions for cleaner code
  defp get_recent_assessment_completions(student_id, limit) do
    Repo.all(
      from(a in "assessment_attempts",
        join: ass in CodeHorizon.Assessments.Assessment,
        on: a.assessment_id == ass.id,
        join: c in CodeHorizon.Courses.Course,
        on: ass.course_id == c.id,
        where: a.student_id == ^student_id and a.status in ["graded", "passed"],
        order_by: [desc: a.updated_at],
        select: %{
          type: :assessment_completed,
          assessment_id: ass.id,
          assessment_title: ass.title,
          course_id: c.id,
          course_title: c.title,
          score: a.score,
          timestamp: a.updated_at
        },
        limit: ^limit
      )
    )
  end

  # Extract recent enrollments for cleaner code
  defp get_recent_enrollments(student_id, limit) do
    Repo.all(
      from(e in CodeHorizon.Enrollments.Enrollment,
        join: c in CodeHorizon.Courses.Course,
        on: e.course_id == c.id,
        where: e.student_id == ^student_id,
        order_by: [desc: e.inserted_at],
        select: %{type: :course_enrolled, course_id: c.id, course_title: c.title, timestamp: e.inserted_at},
        limit: ^limit
      )
    )
  end

  # Check for milestone reached (25%, 50%, 75%, 100%)
  defp check_for_milestone(enrollment_id, previous_percent, current_percent) do
    milestones = [25, 50, 75, 100]

    # Find crossed milestones
    crossed_milestones =
      Enum.filter(milestones, fn milestone ->
        previous_percent < milestone && current_percent >= milestone
      end)

    if Enum.any?(crossed_milestones) do
      # Get course info for context
      enrollment =
        enrollment_id
        |> Enrollments.get_enrollment!()
        |> Repo.preload(course: [:title])

      # Broadcast for each milestone
      Enum.each(crossed_milestones, fn milestone ->
        Events.broadcast_milestone_reached(
          enrollment_id,
          milestone,
          enrollment.course.title
        )
      end)
    end
  end

  # Check and update enrollment if course is completed
  defp check_and_update_enrollment_progress(enrollment_id) do
    percent = calculate_enrollment_progress(enrollment_id)

    # If 100% complete, mark enrollment as completed
    if percent == 100 do
      enrollment = Enrollments.get_enrollment!(enrollment_id)

      # Using atom comparison
      if enrollment.status != :completed do
        Enrollments.update_enrollment(enrollment, %{status: :completed})
      end
    end
  end
end
