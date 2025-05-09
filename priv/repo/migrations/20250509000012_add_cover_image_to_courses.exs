defmodule CodeHorizon.Repo.Migrations.AddCoverImageToCourses do
  use Ecto.Migration

  def change do
    alter table(:courses) do
      add :cover_image, :string
    end
  end
end
