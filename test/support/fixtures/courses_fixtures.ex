defmodule CodeHorizon.CoursesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `CodeHorizon.Courses` context.
  """

  @doc """
  Generate a unique course slug.
  """
  def unique_course_slug, do: "some slug#{System.unique_integer([:positive])}"

  @doc """
  Generate a course.
  """
  def course_fixture(attrs \\ %{}) do
    {:ok, course} =
      attrs
      |> Enum.into(%{
        description: "some description",
        featured_order: 42,
        is_published: true,
        level: :beginner,
        slug: unique_course_slug(),
        title: "some title"
      })
      |> CodeHorizon.Courses.create_course()

    course
  end
end
