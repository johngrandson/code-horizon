defmodule CodeHorizon.Repo.Migrations.CreateQuestionOptions do
  use Ecto.Migration

  def change do
    create table(:question_options) do
      add :option_text, :text
      add :is_correct, :boolean, default: false, null: false
      add :order, :integer
      add :question_id, references(:questions, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:question_options, [:question_id])
  end
end
