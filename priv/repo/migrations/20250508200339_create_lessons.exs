defmodule CodeHorizon.Repo.Migrations.CreateLessons do
  use Ecto.Migration

  def change do
    create table(:lessons) do
      add :title, :string
      add :content, :text
      add :order, :integer
      add :course_id, references(:courses, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:lessons, [:course_id])
  end
end
