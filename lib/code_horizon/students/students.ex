defmodule CodeHorizon.Students do
  @moduledoc """
  The Students context.
  Provides aggregated views and operations specific to student experiences.
  Acts as an adapter between the domain layer (LMS) and the presentation layer.
  """

  alias CodeHorizon.Assessments
  alias CodeHorizon.Courses
  alias CodeHorizon.Enrollments
  alias CodeHorizon.ProgressTracking
  alias CodeHorizon.Repo
  alias CodeHorizon.Students.StudentDashboard

  @doc """
  Returns a dashboard projection for a specific student.
  Aggregates data from various domain sources to create a comprehensive
  view optimized for the student's dashboard UI.

  ## Examples
      iex> get_student_dashboard!(student_id)
      %StudentDashboard{...}
  """
  def get_student_dashboard!(student_id) do
    # Collect all required data from domain services
    enrolled_courses = get_enrolled_courses(student_id)
    upcoming_assessments = get_upcoming_assessments(student_id)
    recent_activity = get_recent_activity(student_id)
    recommended_courses = get_recommended_courses(student_id)
    learning_stats = calculate_learning_stats(enrolled_courses)

    # Project into the dashboard view model
    %StudentDashboard{
      id: student_id,
      enrolled_courses: enrolled_courses,
      upcoming_assessments: upcoming_assessments,
      recent_activity: recent_activity,
      recommended_courses: recommended_courses,
      learning_stats: learning_stats
    }
  end

  @doc """
  Returns a list of courses the student is enrolled in, with progress information.

  ## Examples
      iex> get_enrolled_courses(student_id)
      [%Enrollment{}, ...]
  """
  def get_enrolled_courses(student_id) do
    Enrollments.list_enrollments_with_progress_by_student(student_id)
  end

  @doc """
  Returns a list of upcoming assessments for the student.

  ## Examples
      iex> get_upcoming_assessments(student_id)
      [%Assessment{}, ...]
  """
  def get_upcoming_assessments(student_id) do
    Assessments.list_upcoming_assessments_for_student(student_id)
  end

  @doc """
  Returns a list of recent activity records for the student.

  ## Examples
      iex> get_recent_activity(student_id)
      [%Progress{}, ...]
  """
  def get_recent_activity(student_id, opts \\ []) do
    limit = Keyword.get(opts, :limit, 5)
    ProgressTracking.get_recent_activity(student_id, limit: limit)
  end

  @doc """
  Returns a list of recommended courses for the student.

  ## Examples
      iex> get_recommended_courses(student_id)
      [
        %{
          id: "c1d2e3f4",
          title: "Advanced Elixir",
          instructor: %{name: "Jane Doe"},
          cover_image: "/images/courses/elixir-advanced.jpg",
          rating: 4.8,
          enrollment_count: 1250
        },
        # ...
      ]
  """
  def get_recommended_courses(student_id) do
    Courses.list_recommended_courses_for_student(student_id, limit: 3)
  end

  @doc """
    Calculates learning statistics based on the student's enrolled courses.

    Returns a map with metrics including completed courses count, total courses,
    courses in progress, and average progress across active courses.

    ## Examples

        iex> calculate_learning_stats(enrolled_courses)
        %{
          completed_courses: 2,
          total_courses: 5,
          courses_in_progress: 3,
          avg_progress: 0.6
        }
  """
  def calculate_learning_stats(enrolled_courses) do
    completed_courses = Enum.count(enrolled_courses, &(&1.status == :completed))
    total_courses = length(enrolled_courses)
    courses_in_progress = Enum.count(enrolled_courses, &(&1.status == :active))

    # Calculate average progress across all active courses
    avg_progress = calculate_average_progress(enrolled_courses)

    %{
      completed_courses: completed_courses,
      total_courses: total_courses,
      courses_in_progress: courses_in_progress,
      avg_progress: avg_progress
    }
  end

  # Extract calculation to a separate function for better readability and testing
  defp calculate_average_progress(enrolled_courses) do
    active_courses = Enum.filter(enrolled_courses, &(&1.status == :active))

    case active_courses do
      [] ->
        0

      courses ->
        total_progress =
          Enum.reduce(courses, 0, fn course, acc ->
            acc + (course.progress || 0)
          end)

        total_progress / length(courses)
    end
  end

  @doc """
  Updates a student dashboard projection with new attributes.
  This is an in-memory operation; no database persistence occurs.

  ## Returns
    - {:ok, %StudentDashboard{}} - The updated dashboard struct
  """
  def update_student_dashboard(%StudentDashboard{} = student_dashboard, attrs \\ %{}) do
    updated_dashboard = struct(StudentDashboard, Map.merge(Map.from_struct(student_dashboard), attrs))
    {:ok, updated_dashboard}
  end

  @doc """
  Creates a new student dashboard projection for a student.
  This aggregates data from multiple contexts into a single view.

  ## Returns
    - {:ok, %StudentDashboard{}} - The created dashboard struct
  """
  def create_student_dashboard(student_id) do
    # Collect domain data from respective contexts
    enrolled_courses = get_enrolled_courses(student_id)

    dashboard = %StudentDashboard{
      id: student_id,
      enrolled_courses: enrolled_courses,
      learning_stats: calculate_learning_stats(enrolled_courses),
      upcoming_assessments: get_upcoming_assessments(student_id),
      recent_activity: get_recent_activity(student_id),
      recommended_courses: get_recommended_courses(student_id)
    }

    {:ok, dashboard}
  end

  @doc """
  Returns a map that can be used to update a StudentDashboard struct.
  This is primarily for compatibility with form handling patterns.

  ## Examples

      iex> change_student_dashboard(dashboard, %{enrolled_courses: new_courses})
      %{data: %StudentDashboard{...}, changes: %{enrolled_courses: new_courses}, valid?: true}
  """
  def change_student_dashboard(%StudentDashboard{} = student_dashboard, attrs \\ %{}) do
    # Returns a map that can be used to update a StudentDashboard struct
    # for compatibility with form handling patterns
    %{
      data: student_dashboard,
      changes: attrs,
      valid?: true
    }
  end

  @doc """
  Deletes a student_dashboard.

  ## Examples
      iex> delete_student_dashboard(student_dashboard)
      {:ok, %StudentDashboard{}}

      iex> delete_student_dashboard(student_dashboard)
      {:error, %Ecto.Changeset{}}
  """
  def delete_student_dashboard(%StudentDashboard{} = student_dashboard) do
    Repo.delete(student_dashboard)
  end
end
