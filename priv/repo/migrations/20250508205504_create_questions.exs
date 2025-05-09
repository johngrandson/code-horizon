defmodule CodeHorizon.Repo.Migrations.CreateQuestions do
  use Ecto.Migration

  def change do
    create table(:questions) do
      add :question_text, :text
      add :question_type, :string
      add :points, :integer
      add :order, :integer
      add :assessment_id, references(:assessments, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:questions, [:assessment_id])
  end
end
