defmodule CodeHorizon.Repo.Migrations.CreateLessons do
  use Ecto.Migration

  def change do
    create table(:lessons) do
      add :title, :string
      add :description, :text
      add :content_type, :string
      add :position, :integer
      add :video_url, :string
      add :duration_minutes, :integer
      add :is_published, :boolean, default: false, null: false
      add :is_free_preview, :boolean, default: false, null: false
      add :module_id, references(:modules, on_delete: :nothing)
      add :course_id, references(:courses, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:lessons, [:module_id])
    create index(:lessons, [:course_id])
  end
end
