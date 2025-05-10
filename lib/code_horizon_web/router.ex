defmodule CodeHorizonWeb.Router do
  use CodeHorizonWeb, :router

  import CodeHorizonWeb.OrgPlugs
  import CodeHorizonWeb.SubscriptionPlugs
  import CodeHorizonWeb.UserAuth

  alias CodeHorizonWeb.OnboardingPlug

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {CodeHorizonWeb.Layouts, :root}
    plug :protect_from_forgery

    plug :put_secure_browser_headers, %{
      "content-security-policy" =>
        ContentSecurityPolicy.serialize(
          struct(ContentSecurityPolicy.Policy, CodeHorizon.config(:content_security_policy))
        )
    }

    plug :fetch_current_user
    plug :fetch_impersonator_user
    plug :kick_user_if_suspended_or_deleted
    plug CodeHorizonWeb.PutUserSocketTokenPlug
    plug CodeHorizonWeb.SetLocalePlug, gettext: CodeHorizonWeb.Gettext
  end

  pipeline :public_layout do
    plug :put_layout, html: {CodeHorizonWeb.Layouts, :public}
  end

  pipeline :authenticated do
    plug CodeHorizonWeb.PutSessionRequestPathPlug
    plug :require_authenticated_user
    plug OnboardingPlug
    plug :assign_org_data
  end

  pipeline :subscribed_entity do
    plug :subscribed_entity_only
  end

  pipeline :subscribed_org do
    plug :subscribed_org_only
  end

  pipeline :subscribed_user do
    plug :subscribed_user_only
  end

  # Public routes
  scope "/", CodeHorizonWeb do
    pipe_through [:browser, :public_layout]

    # Add public controller routes here
    get "/", PageController, :landing_page
    get "/privacy", PageController, :privacy
    get "/license", PageController, :license

    live_session :public, layout: {CodeHorizonWeb.Layouts, :public} do
      # Add public live routes here
      live "/blog", BlogLive.Index, :index
      live "/blog/:slug", BlogLive.Show, :show
    end
  end

  # App routes - for signed in and confirmed users only
  scope "/app", CodeHorizonWeb do
    pipe_through [:browser, :authenticated]

    # Add controller authenticated routes here
    put "/users/settings/update-password", UserSettingsController, :update_password
    get "/users/settings/confirm-email/:token", UserSettingsController, :confirm_email
    get "/users/totp", UserTOTPController, :new
    post "/users/totp", UserTOTPController, :create

    live_session :authenticated,
      on_mount: [
        {CodeHorizonWeb.UserOnMountHooks, :attach_read_relevant_notifications_hook},
        {CodeHorizonWeb.UserOnMountHooks, :require_authenticated_user},
        {CodeHorizonWeb.OrgOnMountHooks, :assign_org_data},
        {CodeHorizonWeb.UserOnMountHooks, :assign_current_org},
        {CodeHorizonWeb.SubscriptionPlugs, :subscribed_entity}
      ] do
      # Add live authenticated routes here

      use CodeHorizonWeb.BillingRoutes
      use CodeHorizonWeb.LMSRoutes
      use CodeHorizonWeb.StudentRoutes
      use CodeHorizonWeb.InstructorRoutes
      use CodeHorizonWeb.TemplatesRoutes

      live "/", DashboardLive

      live "/users/onboarding", UserOnboardingLive
      live "/users/edit-profile", EditProfileLive
      live "/users/edit-email", EditEmailLive
      live "/users/change-password", EditPasswordLive
      live "/users/edit-notifications", EditNotificationsLive
      live "/users/org-invitations", UserOrgInvitationsLive
      live "/users/two-factor-authentication", EditTotpLive

      live "/ai-chat", UserAiChatLive

      live "/orgs", OrgsLive, :index
      live "/orgs/new", OrgsLive, :new

      scope "/org/:org_slug" do
        live "/", OrgDashboardLive
        live "/edit", EditOrgLive
        live "/team", OrgTeamLive, :index
        live "/team/invite", OrgTeamLive, :invite
        live "/team/memberships/:id/edit", OrgTeamLive, :edit_membership
      end
    end
  end

  if CodeHorizon.config(:impersonation_enabled?) do
    use CodeHorizonWeb.AuthImpersonationRoutes
  end

  scope "/" do
    use CodeHorizonWeb.AuthRoutes
    use CodeHorizonWeb.SubscriptionRoutes
    use CodeHorizonWeb.MailblusterRoutes
    use CodeHorizonWeb.AdminRoutes
    use CodeHorizonApi.Routes

    # DevRoutes must always be last
    use CodeHorizonWeb.DevRoutes
  end
end
