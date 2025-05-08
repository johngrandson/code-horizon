defmodule CodeHorizon.Repo do
  use Ecto.Repo,
    otp_app: :code_horizon,
    adapter: Ecto.Adapters.Postgres

  use CodeHorizon.Extensions.Ecto.RepoExt
end
