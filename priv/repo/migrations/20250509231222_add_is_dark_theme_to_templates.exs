defmodule CodeHorizon.Repo.Migrations.AddIsDarkThemeToTemplates do
  use Ecto.Migration

  def change do
    alter table(:templates) do
      add :is_dark_theme, :boolean, default: false
    end
  end
end
