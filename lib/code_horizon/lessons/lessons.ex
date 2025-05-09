defmodule CodeHorizon.Lessons do
  @moduledoc """
  The Lessons context.
  """

  import Ecto.Query, warn: false

  alias CodeHorizon.Lessons.Events
  alias CodeHorizon.Lessons.Lesson
  alias CodeHorizon.Repo

  require Logger

  @doc """
  Returns the list of lessons.

  ## Examples

      iex> list_lessons()
      [%Lesson{}, ...]

  """
  def list_lessons do
    Repo.all(Lesson)
  end

  @doc """
  Returns the list of lessons for a course.

  ## Examples

      iex> list_lessons_by_course(1)
      [%Lesson{}, ...]

  """
  def list_lessons_by_course(course_id) do
    Repo.all(from(l in Lesson, where: l.course_id == ^course_id))
  end

  @doc """
  Gets a single lesson.

  Raises `Ecto.NoResultsError` if the Lesson does not exist.

  ## Examples

      iex> get_lesson!(123)
      %Lesson{}

      iex> get_lesson!(456)
      ** (Ecto.NoResultsError)

  """
  def get_lesson!(id), do: Repo.get!(Lesson, id)

  @doc """
  Creates a lesson.

  ## Examples

      iex> Lessons.create_lesson(%{
        title: "some title",
        course_id: 1,
        order: 1,
        content: "some content"
      })
      {:ok, %Lesson{}}

      iex> create_lesson(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_lesson(attrs \\ %{}) do
    %Lesson{}
    |> Lesson.changeset(attrs)
    |> Repo.insert()
    |> broadcast_on_success(&Events.broadcast_created/1)
  end

  @doc """
  Updates a lesson.

  ## Examples

      iex> update_lesson(lesson, %{field: new_value})
      {:ok, %Lesson{}}

      iex> update_lesson(lesson, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_lesson(%Lesson{} = lesson, attrs) do
    lesson
    |> Lesson.changeset(attrs)
    |> Repo.update()
    |> broadcast_on_success(&Events.broadcast_updated/1)
  end

  @doc """
  Deletes a lesson.

  ## Examples

      iex> delete_lesson(lesson)
      {:ok, %Lesson{}}

      iex> delete_lesson(lesson)
      {:error, %Ecto.Changeset{}}

  """
  def delete_lesson(%Lesson{} = lesson) do
    lesson
    |> Repo.delete()
    |> broadcast_on_success(&Events.broadcast_deleted/1)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking lesson changes.

  ## Examples

      iex> change_lesson(lesson)
      %Ecto.Changeset{data: %Lesson{}}

  """
  def change_lesson(%Lesson{} = lesson, attrs \\ %{}) do
    Lesson.changeset(lesson, attrs)
  end

  @doc """
  Handles the deletion of a course by archiving its lessons or
  performing other cleanup actions.

  ## Examples
      iex> handle_course_deletion("course-123")
      {n, nil}  # n is the number of updated records
  """
  def handle_course_deletion(course_id) do
    # Option 1: Archive the lessons (set an archived flag)
    # from(l in Lesson, where: l.course_id == ^course_id)
    # |> Repo.update_all(set: [archived: true])

    # Option 2: For this example, we'll mark them with a status
    Repo.update_all(from(l in Lesson, where: l.course_id == ^course_id), set: [status: "course_deleted"])

    # Note: You might need to add a status field to your Lesson schema
    # if you choose option 2, via a migration:
    # add :status, :string, default: "active"
  end

  @doc """
  Validates lessons for a newly published course, ensuring the course
  has sufficient and appropriate content.

  ## Examples
      iex> validate_lessons_for_published_course("course-123")
      :ok
  """
  def validate_lessons_for_published_course(course_id) do
    # Count lessons for the course
    lesson_count =
      Repo.aggregate(from(l in Lesson, where: l.course_id == ^course_id), :count, :id)

    # Validate course has at least one lesson
    if lesson_count == 0 do
      # Log a warning about empty published course
      Logger.warning("Course #{course_id} was published without any lessons")

      # You could also notify administrators:
      # CodeHorizon.Notifications.notify_admins("Empty course published",
      #   "Course #{course_id} was published but contains no lessons."
      # )
    end

    # Could perform other validations here:
    # - Check for lessons with empty content
    # - Ensure proper lesson ordering
    # - Validate required lesson types exist

    :ok
  end

  def complete_lesson(lesson_id, student_id) do
    with {:ok, lesson} <- get_lesson!(lesson_id) do
      # Here we could update the student's progress tracking

      # Broadcast the completed event
      Events.broadcast_completed(lesson, student_id)

      {:ok, lesson}
    end
  end

  # Helper function to broadcast events on successful operations
  defp broadcast_on_success({:ok, result} = success, broadcast_fn) do
    broadcast_fn.(result)
    success
  end

  defp broadcast_on_success(error, _broadcast_fn), do: error
end
