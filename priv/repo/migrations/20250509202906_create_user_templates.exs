defmodule CodeHorizon.Repo.Migrations.CreateUserTemplates do
  use Ecto.Migration

  def change do
    create table(:user_templates) do
      add :is_active, :boolean, default: false, null: false
      add :user_id, references(:users, on_delete: :nothing)
      add :template_id, references(:templates, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:user_templates, [:user_id])
    create index(:user_templates, [:template_id])
    create unique_index(:user_templates, [:user_id, :template_id])
  end
end
