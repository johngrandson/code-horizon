defmodule CodeHorizon.LessonsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `CodeHorizon.Lessons` context.
  """

  @doc """
  Generate a lesson.
  """
  def lesson_fixture(attrs \\ %{}) do
    {:ok, lesson} =
      attrs
      |> Enum.into(%{
        content: "some content",
        order: 42,
        title: "some title"
      })
      |> CodeHorizon.Lessons.create_lesson()

    lesson
  end
end
