defmodule CodeHorizon.Enrollments do
  @moduledoc """
  The Enrollments context.
  """

  import Ecto.Query, warn: false

  alias CodeHorizon.Enrollments.Enrollment
  alias CodeHorizon.Enrollments.Events
  alias CodeHorizon.EventBus
  alias CodeHorizon.Lessons.Lesson
  alias CodeHorizon.ProgressTracking.Progress
  alias CodeHorizon.Repo

  @doc """
  Returns the list of enrollments.

  ## Examples

      iex> list_enrollments()
      [%Enrollment{}, ...]

  """
  def list_enrollments do
    Repo.all(Enrollment)
  end

  @doc """
  Returns the list of enrollments for a student.

  ## Examples

      iex> list_enrollments_by_student_id(123)
      [%Enrollment{}, ...]

  """
  def list_enrollments_by_student_id(student_id) do
    Repo.all(from e in Enrollment, where: e.student_id == ^student_id)
  end

  @doc """
  Lists enrollments with progress statistics for a student.

  Returns a list of enriched enrollment maps containing:
  - Basic enrollment data (id, status, etc)
  - Course data (title, instructor)
  - Progress metrics (total_lessons, completed_lessons, progress percentage)
  """
  def list_enrollments_with_progress_by_student(student_id) do
    enrollments =
      Enrollment
      |> where([e], e.student_id == ^student_id)
      |> join(:inner, [e], c in assoc(e, :course))
      |> preload([_, c], course: [instructor: []])
      |> Repo.all()

    Enum.map(enrollments, fn enrollment ->
      progress_stats = get_enrollment_progress_stats(enrollment.id, enrollment.course.id)

      %{
        id: enrollment.id,
        course_id: enrollment.course.id,
        title: enrollment.course.title,
        status: enrollment.status,
        level: enrollment.course.level,
        enrolled_at: enrollment.enrolled_at,
        description: enrollment.course.description,
        instructor_id: enrollment.course.instructor_id,
        instructor: enrollment.course.instructor,
        total_lessons: progress_stats.total_lessons,
        completed_lessons: progress_stats.completed_lessons,
        progress: progress_stats.progress,
        cover_image: enrollment.course.cover_image,
        instructor_name: enrollment.course.instructor.name
      }
    end)
  end

  @doc """
  Gets an enrollment by student ID and course ID.
  Returns a single enrollment or nil if none exists.

  ## Examples

      iex> get_enrollment_by_student_and_course(student_id, course_id)
      %Enrollment{}

      iex> get_enrollment_by_student_and_course(student_id, non_existing_course_id)
      nil
  """
  def get_enrollment_by_student_and_course(student_id, course_id) do
    Repo.one(
      from e in Enrollment,
        where: e.student_id == ^student_id and e.course_id == ^course_id,
        limit: 1
    )
  end

  @doc """
  Gets a single enrollment.

  Raises `Ecto.NoResultsError` if the Enrollment does not exist.

  ## Examples

      iex> get_enrollment!(123)
      %Enrollment{}

      iex> get_enrollment!(456)
      ** (Ecto.NoResultsError)

  """
  def get_enrollment!(id), do: Repo.get!(Enrollment, id)

  @doc """
  Creates a enrollment.

  ## Examples

      iex> Enrollments.create_enrollment(%{
        status: :active,
        enrolled_at: ~U[2025-05-07 20:32:00Z],
        expires_at: ~U[2025-05-07 20:32:00Z],
        student_id: 1,
        course_id: 1
      })
      {:ok, %Enrollment{}}

      iex> create_enrollment(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_enrollment(attrs \\ %{}) do
    %Enrollment{}
    |> Enrollment.changeset(attrs)
    |> Repo.insert()
    |> EventBus.broadcast_on_success(&Events.student_enrolled/1)
  end

  @doc """
  Updates an enrollment with the given attributes, ensuring proper state
  transitions and domain event publications.

  This operation is transactional - both the database update and the event
  publications are handled atomically.

  ## Parameters
    - enrollment: The enrollment struct to update
    - attrs: Map of attributes to update

  ## Returns
    - {:ok, %Enrollment{}} - Updated enrollment on success
    - {:error, %Ecto.Changeset{}} - Error changeset on validation failure

  ## Examples

      iex> update_enrollment(enrollment, %{status: "completed"})
      {:ok, %Enrollment{status: "completed", ...}}
  """
  def update_enrollment(%Enrollment{} = enrollment, attrs) do
    # Capture previous status for state transition detection
    previous_status = enrollment.status

    # Extract new status from attrs (respecting both string and atom keys)
    new_status = Map.get(attrs, :status) || Map.get(attrs, "status")

    # Validate state transition if status is changing
    if new_status && !valid_status_transition?(previous_status, new_status) do
      changeset = Enrollment.changeset(enrollment, attrs)

      {:error,
       Ecto.Changeset.add_error(changeset, :status, "Invalid status transition from #{previous_status} to #{new_status}")}
    else
      Ecto.Multi.new()
      |> Ecto.Multi.update(:enrollment, Enrollment.changeset(enrollment, attrs))
      |> Ecto.Multi.run(:events, fn _repo, %{enrollment: updated_enrollment} ->
        # Publish events based on detected state transitions
        Events.enrollment_details_updated(updated_enrollment)

        # Handle specific domain events for state transitions
        cond do
          previous_status != :completed && updated_enrollment.status == :completed ->
            Events.course_completed(updated_enrollment)

          previous_status != :cancelled && updated_enrollment.status == :cancelled ->
            Events.enrollment_cancelled(updated_enrollment)

          previous_status != :expired && updated_enrollment.status == :expired ->
            Events.enrollment_expired(updated_enrollment)

          true ->
            # No special state transition
            :ok
        end

        {:ok, nil}
      end)
      |> Repo.transaction()
      |> handle_transaction_result(enrollment.id)
    end
  end

  # Private helper functions for cleaner implementation

  defp get_enrollment_progress_stats(enrollment_id, course_id) do
    total_query =
      from l in Lesson,
        where: l.course_id == ^course_id,
        select: count(l.id)

    completed_status = :completed

    completed_query =
      from p in Progress,
        join: l in Lesson,
        on: p.lesson_id == l.id,
        where: p.enrollment_id == ^enrollment_id,
        where: p.completion_status == ^completed_status,
        where: l.course_id == ^course_id,
        select: count(p.id)

    total_lessons = Repo.one(total_query) || 0
    completed_lessons = Repo.one(completed_query) || 0

    progress =
      case total_lessons do
        0 -> 0
        _ -> floor(completed_lessons * 100 / total_lessons)
      end

    %{
      total_lessons: total_lessons,
      completed_lessons: completed_lessons,
      progress: progress
    }
  end

  @doc false
  defp valid_status_transition?(from, to) do
    # Define valid state transitions in the domain
    valid_transitions = %{
      "active" => [:completed, :cancelled, :paused, :expired],
      "paused" => [:active, :cancelled, :expired],
      # Terminal state
      "completed" => [],
      # Terminal state
      "cancelled" => [],
      # Terminal state
      "expired" => []
    }

    # String conversion for consistently handling both string and atom status values
    from_str = to_string(from)
    to_str = to_string(to)

    # No transition is always valid (updating other fields)
    from_str == to_str || to_str in (valid_transitions[from_str] || [])
  end

  @doc false
  defp handle_transaction_result(transaction_result, enrollment_id) do
    case transaction_result do
      {:ok, %{enrollment: enrollment}} ->
        {:ok, enrollment}

      {:error, :enrollment, changeset, _} ->
        {:error, changeset}

      {:error, :events, reason, _changes_so_far} ->
        # Log error but don't fail the operation since DB update succeeded
        require Logger

        Logger.error("Failed to publish enrollment events: #{inspect(reason)}")

        # Fetch the updated enrollment to return it
        {:ok, Repo.get!(Enrollment, enrollment_id)}
    end
  end

  @doc """
  Deletes a enrollment.

  ## Examples

      iex> delete_enrollment(enrollment)
      {:ok, %Enrollment{}}

      iex> delete_enrollment(enrollment)
      {:error, %Ecto.Changeset{}}

  """
  def delete_enrollment(%Enrollment{} = enrollment) do
    Repo.delete(enrollment)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking enrollment changes.

  ## Examples

      iex> change_enrollment(enrollment)
      %Ecto.Changeset{data: %Enrollment{}}

  """
  def change_enrollment(%Enrollment{} = enrollment, attrs \\ %{}) do
    Enrollment.changeset(enrollment, attrs)
  end

  @doc """
  Cancels an enrollment, setting its status to cancelled and broadcasting appropriate events.
  """
  def cancel_enrollment(%Enrollment{} = enrollment) do
    update_enrollment(enrollment, %{status: :cancelled})
  end

  @doc """
  Marks an enrollment as completed and broadcasts a completion event.
  """
  def complete_enrollment(%Enrollment{} = enrollment) do
    update_enrollment(enrollment, %{status: :completed})
  end

  @doc """
  Handles enrollment expiration, marking it as expired and broadcasting an event.
  """
  def expire_enrollment(%Enrollment{} = enrollment) do
    # First update the enrollment
    {:ok, updated_enrollment} = update_enrollment(enrollment, %{status: :expired})

    # Then broadcast the specific event
    Events.enrollment_expired(updated_enrollment)

    {:ok, updated_enrollment}
  end
end
