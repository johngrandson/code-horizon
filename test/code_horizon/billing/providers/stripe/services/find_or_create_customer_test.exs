defmodule CodeHorizon.Billing.Providers.Stripe.Services.FindOrCreateCustomerTest do
  use CodeHorizon.DataCase

  import CodeHorizon.AccountsFixtures
  import CodeHorizon.BillingFixtures

  alias CodeHorizon.Billing.Customers.Customer
  alias CodeHorizon.Billing.Providers.Stripe.Services.FindOrCreateCustomer
  alias CodeHorizon.Repo

  describe "call/3" do
    test "finds a customer" do
      user = confirmed_user_fixture()

      billing_customer_fixture(%{user_id: user.id})

      assert Repo.count(Customer) == 1

      assert {:ok, %Customer{}} = FindOrCreateCustomer.call(user, :user, user.id)

      assert Repo.count(Customer) == 1
    end

    test "creates a customer" do
      user = confirmed_user_fixture()

      assert Repo.count(Customer) == 0

      use_cassette "CodeHorizon.Billing.Providers.Stripe.Services.FindOrCreateCustomer.call" do
        assert {:ok, %Customer{}} = FindOrCreateCustomer.call(user, :user, user.id)
      end

      assert Repo.count(Customer) == 1
    end
  end
end
