defmodule CodeHorizon.Repo.Migrations.AddPreviewImageToTemplates do
  use Ecto.Migration

  def change do
    alter table(:templates) do
      add :preview_image, :string, default: "/images/templates/default.png"
    end
  end
end
