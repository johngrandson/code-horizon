defmodule CodeHorizon.Repo.Migrations.CreateCourses do
  use Ecto.Migration

  def change do
    create table(:courses) do
      add :title, :string
      add :description, :text
      add :slug, :string
      add :cover_image, :string
      add :price, :decimal
      add :status, :string
      add :level, :string
      add :estimated_duration_minutes, :integer
      add :is_featured, :boolean, default: false, null: false
      add :user_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:courses, [:user_id])
  end
end
