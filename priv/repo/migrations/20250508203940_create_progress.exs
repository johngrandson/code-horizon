defmodule CodeHorizon.Repo.Migrations.CreateProgress do
  use Ecto.Migration

  def change do
    create table(:progress) do
      add :completion_status, :string
      add :percent_complete, :integer
      add :last_accessed_at, :utc_datetime
      add :completion_date, :utc_datetime
      add :enrollment_id, references(:enrollments, on_delete: :nothing)
      add :lesson_id, references(:lessons, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:progress, [:enrollment_id])
    create index(:progress, [:lesson_id])
  end
end
