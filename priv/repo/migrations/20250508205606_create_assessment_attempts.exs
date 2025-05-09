defmodule CodeHorizon.Repo.Migrations.CreateAssessmentAttempts do
  use Ecto.Migration

  def change do
    create table(:assessment_attempts) do
      add :score, :integer
      add :status, :string
      add :start_time, :utc_datetime
      add :end_time, :utc_datetime
      add :assessment_id, references(:assessments, on_delete: :nothing)
      add :student_id, references(:users, on_delete: :nothing)
      add :enrollment_id, references(:enrollments, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:assessment_attempts, [:assessment_id])
    create index(:assessment_attempts, [:student_id])
    create index(:assessment_attempts, [:enrollment_id])
  end
end
