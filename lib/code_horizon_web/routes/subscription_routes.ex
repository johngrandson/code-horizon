defmodule CodeHorizonWeb.SubscriptionRoutes do
  @moduledoc false
  defmacro __using__(_) do
    quote do
      scope "/app", CodeHorizonWeb do
        pipe_through [:browser, :authenticated, :subscribed_user]

        get "/subscribed", PageController, :subscribed

        live_session :subscription_authenticated_user,
          on_mount: [
            {CodeHorizonWeb.UserOnMountHooks, :require_authenticated_user},
            {CodeHorizonWeb.OrgOnMountHooks, :assign_org_data},
            {CodeHorizonWeb.SubscriptionPlugs, :subscribed_user}
          ] do
          live "/subscribed_live", SubscribedLive
        end
      end

      scope "/app", CodeHorizonWeb do
        pipe_through [:browser, :authenticated, :subscribed_org]

        scope "/org/:org_slug" do
          get "/subscribed", PageController, :subscribed

          live_session :subscription_authenticated_org,
            on_mount: [
              {CodeHorizonWeb.UserOnMountHooks, :require_authenticated_user},
              {CodeHorizonWeb.OrgOnMountHooks, :assign_org_data},
              {CodeHorizonWeb.SubscriptionPlugs, :subscribed_org}
            ] do
            live "/subscribed_live", SubscribedLive
          end
        end
      end
    end
  end
end
