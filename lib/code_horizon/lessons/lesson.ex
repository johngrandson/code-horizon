defmodule CodeHorizon.Lessons.Lesson do
  @moduledoc false
  use CodeHorizon.Schema

  typed_schema "lessons" do
    field :title, :string
    field :content, :string
    field :order, :integer

    belongs_to :course, CodeHorizon.Courses.Course

    timestamps()
  end

  @doc false
  def changeset(lesson, attrs) do
    lesson
    |> cast(attrs, [:title, :content, :order, :course_id])
    |> validate_required([:title, :content, :order, :course_id])
  end
end
