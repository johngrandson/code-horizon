defmodule CodeHorizon.Repo.Migrations.CreateCourses do
  use Ecto.Migration

  def change do
    create table(:courses) do
      add :title, :string
      add :description, :text
      add :level, :string
      add :is_published, :boolean, default: false, null: false
      add :featured_order, :integer
      add :slug, :string
      add :instructor_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create unique_index(:courses, [:slug])
    create index(:courses, [:instructor_id])
  end
end
