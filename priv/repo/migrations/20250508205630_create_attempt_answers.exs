defmodule CodeHorizon.Repo.Migrations.CreateAttemptAnswers do
  use Ecto.Migration

  def change do
    create table(:attempt_answers) do
      add :answer_text, :text
      add :is_correct, :boolean, default: false, null: false
      add :points_awarded, :integer
      add :attempt_id, references(:assessment_attempts, on_delete: :nothing)
      add :question_id, references(:questions, on_delete: :nothing)
      add :selected_option_id, references(:question_options, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:attempt_answers, [:attempt_id])
    create index(:attempt_answers, [:question_id])
    create index(:attempt_answers, [:selected_option_id])
  end
end
