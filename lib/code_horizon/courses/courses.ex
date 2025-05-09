defmodule CodeHorizon.Courses do
  @moduledoc """
  The Courses context.
  """

  import Ecto.Query, warn: false

  alias CodeHorizon.Courses.Course
  alias CodeHorizon.Courses.Events
  alias CodeHorizon.Enrollments
  alias CodeHorizon.EventBus
  alias CodeHorizon.Repo

  @doc """
  Returns the list of courses.

  ## Examples

      iex> list_courses()
      [%Course{}, ...]

  """
  def list_courses do
    Repo.all(Course)
  end

  @doc """
  Returns the list of recommended courses for a student.

  ## Examples

      iex> list_recommended_courses_by_student_id(123)
      [%Course{}, ...]

  """
  def list_recommended_courses_by_student_id(student_id) do
    Repo.all(
      from c in Course,
        where: c.is_published == true,
        where: c.id not in ^Enrollments.list_enrollments_by_student_id(student_id),
        order_by: [desc: c.inserted_at]
    )
  end

  @doc """
  Gets a single course.

  Raises `Ecto.NoResultsError` if the Course does not exist.

  ## Examples

      iex> get_course!(123)
      %Course{}

      iex> get_course!(456)
      ** (Ecto.NoResultsError)

  """
  def get_course!(id), do: Repo.get!(Course, id)

  @doc """
  Creates a course and broadcasts a creation event.

  ## Examples
      iex> Courses.create_course(%{
        title: "Elixir Basics",
        description: "Learn the basics of Elixir",
        level: :beginner,
        featured_order: 1
      })
      {:ok, %Course{}}
  """
  def create_course(attrs \\ %{}) do
    %Course{}
    |> Course.changeset(attrs)
    |> Repo.insert()
    |> EventBus.broadcast_on_success(&Events.broadcast_created/1)
  end

  @doc """
  Updates a course and broadcasts appropriate events.
  Detects state transitions like publishing for specialized events.

  ## Examples
      iex> update_course(course, %{title: "Updated Title"})
      {:ok, %Course{}}
  """
  def update_course(%Course{} = course, attrs) do
    was_published = course.is_published

    result =
      course
      |> Course.changeset(attrs)
      |> Repo.update()

    case result do
      {:ok, updated_course} = success ->
        # Broadcast the updated course
        Events.broadcast_updated(updated_course)

        # Detect publish state transition
        if !was_published && updated_course.is_published do
          Events.broadcast_published(updated_course)
        end

        # Detect unpublish state transition
        if was_published && !updated_course.is_published do
          Events.broadcast_unpublished(updated_course)
        end

        success

      error ->
        error
    end
  end

  @doc """
  Deletes a course and broadcasts a deletion event.

  ## Examples
      iex> delete_course(course)
      {:ok, %Course{}}
  """
  def delete_course(%Course{} = course) do
    course
    |> Repo.delete()
    |> EventBus.broadcast_on_success(&Events.broadcast_deleted/1)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking course changes.

  ## Examples

      iex> change_course(course)
      %Ecto.Changeset{data: %Course{}}

  """
  def change_course(%Course{} = course, attrs \\ %{}) do
    Course.changeset(course, attrs)
  end

  @doc """
  Lists recommended courses for a student based on their learning history.
  Returns courses the student is not enrolled in that might be of interest.

  ## Examples

      iex> list_recommended_courses_for_student(student_id, limit: 3)
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
  def list_recommended_courses_for_student(student_id, opts \\ []) do
    limit = Keyword.get(opts, :limit, 3)

    # Get courses the student is already enrolled in
    enrolled_course_ids_query =
      from e in CodeHorizon.Enrollments.Enrollment,
        where: e.student_id == ^student_id,
        select: e.course_id

    enrolled_course_ids = Repo.all(enrolled_course_ids_query)

    # In a real recommendation system, you'd use more sophisticated algorithms
    # For simplicity, we'll just return popular courses the student isn't enrolled in
    Repo.all(
      from c in Course,
        where: c.id not in ^enrolled_course_ids and c.is_published == true,
        join: u in assoc(c, :instructor),
        left_join: e in "enrollments",
        on: e.course_id == c.id,
        group_by: [c.id, u.id, u.name],
        order_by: [desc: count(e.id), desc: c.featured_order],
        limit: ^limit,
        select: %{
          id: c.id,
          title: c.title,
          description: c.description,
          rating: 5,
          is_free: false,
          tags: [:technology, :web_development],
          category: nil,
          duration: nil,
          price: 500,
          review_count: 20,
          discount_percentage: 20,
          original_price: 1000,
          key_benefits: ["Learn Elixir", "Build Web Apps", "Get a Job"],
          is_in_cart: true,
          is_new: true,
          content_count: 10,
          content_type: :video,
          level: c.level,
          is_premium: true,
          instructor: %{id: u.id, name: u.name, avatar: u.avatar, is_verified: true},
          cover_image: c.cover_image,
          enrollment_count: count(e.id),
          last_updated: c.updated_at
        }
    )
  end
end
