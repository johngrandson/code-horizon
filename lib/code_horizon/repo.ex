defmodule CodeHorizon.Repo do
  use Ecto.Repo,
    otp_app: :code_horizon,
    adapter: Ecto.Adapters.Postgres,
    charset: "utf8"

  use CodeHorizon.Extensions.Ecto.RepoExt
end
