defmodule CodeHorizon.Repo.Migrations.CreateModules do
  use Ecto.Migration

  def change do
    create table(:modules) do
      add :title, :string
      add :description, :text
      add :position, :integer
      add :is_published, :boolean, default: false, null: false
      add :course_id, references(:courses, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:modules, [:course_id])
  end
end
