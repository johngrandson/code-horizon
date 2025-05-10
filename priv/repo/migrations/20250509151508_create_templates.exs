defmodule CodeHorizon.Repo.Migrations.CreateTemplates do
  use Ecto.Migration

  def change do
    create table(:templates) do
      add :name, :string
      add :description, :string
      add :primary_color, :string
      add :accent_color, :string
      add :is_default, :boolean, default: false, null: false
      add :created_by_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:templates, [:created_by_id])
  end
end
