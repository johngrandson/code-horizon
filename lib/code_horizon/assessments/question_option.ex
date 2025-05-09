defmodule CodeHorizon.Assessments.QuestionOption do
  @moduledoc false
  use CodeHorizon.Schema

  alias CodeHorizon.Assessments.Question

  typed_schema "question_options" do
    field :order, :integer
    field :option_text, :string
    field :is_correct, :boolean, default: false

    belongs_to :question, Question

    timestamps()
  end

  @doc false
  def changeset(question_option, attrs) do
    question_option
    |> cast(attrs, [:option_text, :is_correct, :order])
    |> validate_required([:option_text, :is_correct, :order])
  end
end
