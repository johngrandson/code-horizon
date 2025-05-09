defmodule CodeHorizon.Assessments.AssessmentAttempt do
  @moduledoc false
  use CodeHorizon.Schema

  alias CodeHorizon.Accounts.User
  alias CodeHorizon.Assessments.Assessment
  alias CodeHorizon.Enrollments.Enrollment

  typed_schema "assessment_attempts" do
    field :status, Ecto.Enum, values: [:in_progress, :submitted, :graded, :passed, :failed]
    field :score, :integer
    field :start_time, :utc_datetime
    field :end_time, :utc_datetime

    belongs_to :assessment, Assessment
    belongs_to :student, User
    belongs_to :enrollment, Enrollment

    timestamps()
  end

  @doc false
  def changeset(assessment_attempt, attrs) do
    assessment_attempt
    |> cast(attrs, [:score, :status, :start_time, :end_time])
    |> validate_required([:score, :status, :start_time, :end_time])
  end
end
