Mimic.copy(CodeHorizon.Notifications.UserMailer)
Mimic.copy(CodeHorizon.Billing.Providers.Stripe.Provider)
Mimic.copy(CodeHorizon.Billing.Providers.Stripe.Services.SyncSubscription)

ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(CodeHorizon.Repo, :manual)
{:ok, _} = Application.ensure_all_started(:wallaby)
Application.put_env(:wallaby, :base_url, CodeHorizonWeb.Endpoint.url())

"screenshots/*"
|> Path.wildcard()
|> Enum.each(&File.rm/1)
