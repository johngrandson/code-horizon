alias CodeHorizon.Accounts
alias CodeHorizon.Accounts.User
alias CodeHorizon.Accounts.UserQuery
alias CodeHorizon.Accounts.UserSeeder
alias CodeHorizon.Billing.Customers
alias CodeHorizon.Billing.Customers.Customer
alias CodeHorizon.Billing.Plans
alias CodeHorizon.Billing.Subscriptions
alias CodeHorizon.Billing.Subscriptions.Subscription
alias CodeHorizon.Logs
alias CodeHorizon.Logs.Log
alias CodeHorizon.MailBluster
alias CodeHorizon.Notifications.UserMailer
alias CodeHorizon.Notifications.UserNotifier
alias CodeHorizon.Orgs
alias CodeHorizon.Orgs.Invitation
alias CodeHorizon.Orgs.Membership
alias CodeHorizon.Repo
alias CodeHorizon.Slack

# Don't cut off inspects with "..."
IEx.configure(inspect: [limit: :infinity])

# Allow copy to clipboard
# eg:
#    iex(1)> Phoenix.Router.routes(CodeHorizonWeb.Router) |> Helpers.copy
#    :ok
defmodule Helpers do
  @moduledoc false
  def copy(term) do
    text =
      if is_binary(term) do
        term
      else
        inspect(term, limit: :infinity, pretty: true)
      end

    port = Port.open({:spawn, "pbcopy"}, [])
    true = Port.command(port, text)
    true = Port.close(port)

    :ok
  end
end
