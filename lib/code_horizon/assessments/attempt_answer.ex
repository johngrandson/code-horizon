defmodule CodeHorizon.Assessments.AttemptAnswer do
  @moduledoc false

  use CodeHorizon.Schema

  alias CodeHorizon.Assessments.AssessmentAttempt
  alias CodeHorizon.Assessments.Question
  alias CodeHorizon.Assessments.QuestionOption

  typed_schema "attempt_answers" do
    field :is_correct, :boolean, default: false
    field :answer_text, :string
    field :points_awarded, :integer

    belongs_to :attempt, AssessmentAttempt
    belongs_to :question, Question
    belongs_to :selected_option, QuestionOption

    timestamps()
  end

  @doc false
  def changeset(attempt_answer, attrs) do
    attempt_answer
    |> cast(attrs, [:answer_text, :is_correct, :points_awarded])
    |> validate_required([:answer_text, :is_correct, :points_awarded])
  end
end
