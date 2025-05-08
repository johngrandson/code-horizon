defmodule CodeHorizon.Billing.Providers.Stripe.Services.SyncCustomerTest do
  use CodeHorizon.DataCase

  import CodeHorizon.AccountsFixtures
  import CodeHorizon.BillingFixtures

  alias CodeHorizon.Billing.Providers.Stripe.Provider
  alias CodeHorizon.Billing.Providers.Stripe.Services.SyncCustomer
  alias CodeHorizon.Billing.Providers.Stripe.Services.SyncSubscription

  test "call/1" do
    user = confirmed_user_fixture()
    customer = billing_customer_fixture(%{user_id: user.id})

    mocked_subscriptions = [1, 2]

    expect(Provider, :list_subscriptions, fn _ -> {:ok, %{data: mocked_subscriptions}} end)
    expect(SyncSubscription, :call, length(mocked_subscriptions), fn _ -> nil end)

    assert :ok = SyncCustomer.call(customer)
  end
end
