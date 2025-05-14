defmodule CodeHorizon.Repo.Migrations.AddIsEnterpriseToUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :is_enterprise, :boolean, default: false
    end
  end
end
