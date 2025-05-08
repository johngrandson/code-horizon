defmodule CodeHorizonWeb.Presence do
  @moduledoc false
  use Phoenix.Presence, otp_app: :code_horizon, pubsub_server: CodeHorizon.PubSub

  alias CodeHorizon.Accounts

  def online_user?(%Accounts.User{} = user) do
    online = not ("users" |> get_by_key(user.id) |> Enum.empty?())
    %{user | is_online: online}
  end

  def online_users(users) when is_list(users) do
    Enum.map(users, &online_user?/1)
  end
end
