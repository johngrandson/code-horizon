defmodule CodeHorizon.Repo.Migrations.CreateAssessments do
  use Ecto.Migration

  def change do
    create table(:assessments) do
      add :title, :string
      add :description, :text
      add :passing_score, :integer
      add :max_attempts, :integer
      add :time_limit_minutes, :integer
      add :assessment_type, :string
      add :is_published, :boolean, default: false, null: false
      add :course_id, references(:courses, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:assessments, [:course_id])
  end
end
