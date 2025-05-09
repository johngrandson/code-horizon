defmodule CodeHorizon.Assessments.Question do
  @moduledoc false
  use CodeHorizon.Schema

  alias CodeHorizon.Assessments.Assessment

  typed_schema "questions" do
    field :order, :integer
    field :question_text, :string
    field :question_type, Ecto.Enum, values: [:multiple_choice, :single_choice, :true_false, :short_answer, :essay]
    field :points, :integer

    belongs_to :assessment, Assessment

    timestamps()
  end

  @doc false
  def changeset(question, attrs) do
    question
    |> cast(attrs, [:question_text, :question_type, :points, :order])
    |> validate_required([:question_text, :question_type, :points, :order])
  end
end
