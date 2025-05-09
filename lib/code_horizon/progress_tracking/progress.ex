defmodule CodeHorizon.ProgressTracking.Progress do
  @moduledoc false
  use CodeHorizon.Schema

  alias CodeHorizon.Enrollments.Enrollment
  alias CodeHorizon.Lessons.Lesson

  typed_schema "progress" do
    field :completion_status, Ecto.Enum, values: [:not_started, :in_progress, :completed]
    field :percent_complete, :integer
    field :last_accessed_at, :utc_datetime
    field :completion_date, :utc_datetime

    belongs_to :enrollment, Enrollment
    belongs_to :lesson, Lesson

    timestamps()
  end

  @doc false
  def changeset(progress, attrs) do
    progress
    |> cast(attrs, [
      :completion_status,
      :percent_complete,
      :last_accessed_at,
      :completion_date,
      :enrollment_id,
      :lesson_id
    ])
    |> validate_required([:completion_status, :percent_complete, :last_accessed_at, :completion_date])
  end
end
