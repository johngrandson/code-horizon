defmodule CodeHorizon.Repo.Migrations.AddBackgroundColorToTemplates do
  use Ecto.Migration

  def change do
    alter table(:templates) do
      add :background_color, :string, default: "#1d293d"
    end
  end
end
