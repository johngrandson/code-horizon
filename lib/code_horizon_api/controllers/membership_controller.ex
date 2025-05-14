defmodule CodeHorizonApi.MembershipController do
  use CodeHorizonWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias CodeHorizon.Accounts
  alias CodeHorizon.Orgs
  alias CodeHorizonApi.Schemas
  alias OpenApiSpex.Reference

  plug :match_current_user

  tags ["membership"]
  security [%{"authorization" => []}]

  action_fallback CodeHorizonWeb.FallbackController

  operation :list,
    summary: "List organizations",
    description: "List organizations for user",
    parameters: [
      id: [in: :path, name: "id", type: :integer]
    ],
    responses: [
      ok: {"Organizations", "application/json", Schemas.OrganizationNames},
      unauthorized: %Reference{"$ref": "#/components/responses/unauthorised"},
      forbidden: %Reference{"$ref": "#/components/responses/forbidden"}
    ]

  def list(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    orgs = Orgs.list_orgs(user)

    (
      org_names = Enum.map(orgs, fn x -> x.name end)

      json(conn, org_names)
    )
  end

  def match_current_user(conn, _params) do
    user_id = String.to_integer(conn.params["id"])
    user = Accounts.get_user!(user_id)

    current_user = conn.assigns.current_user

    if !current_user.is_admin && current_user.id != user_id do
      conn
      |> put_status(:forbidden)
      |> put_view(html: PetalProWeb.ErrorHTML, json: PetalProWeb.ErrorJSON)
      |> render(:"403")
      |> halt()
    else
      assign(conn, :user, user)
    end
  end
end
