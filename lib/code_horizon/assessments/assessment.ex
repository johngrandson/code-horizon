defmodule CodeHorizon.Assessments.Assessment do
  @moduledoc false
  use CodeHorizon.Schema

  alias CodeHorizon.Courses.Course

  typed_schema "assessments" do
    field :max_attempts, :integer
    field :description, :string
    field :title, :string
    field :passing_score, :integer
    field :time_limit_minutes, :integer
    field :assessment_type, Ecto.Enum, values: [:quiz, :assignment, :exam]
    field :is_published, :boolean, default: false

    belongs_to :course, Course

    timestamps()
  end

  @doc false
  def changeset(assessment, attrs) do
    assessment
    |> cast(attrs, [
      :title,
      :description,
      :passing_score,
      :max_attempts,
      :time_limit_minutes,
      :assessment_type,
      :is_published
    ])
    |> validate_required([
      :title,
      :description,
      :passing_score,
      :max_attempts,
      :time_limit_minutes,
      :assessment_type,
      :is_published
    ])
  end
end
