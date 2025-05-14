defmodule CodeHorizonApi.MembershipControllerTest do
  use CodeHorizonWeb.ConnCase

  setup %{conn: conn} do
    user = PetalPro.AccountsFixtures.confirmed_user_fixture()
    other_user = PetalPro.AccountsFixtures.user_fixture()
    admin_user = PetalPro.AccountsFixtures.admin_fixture(%{is_admin: true})
    org = PetalPro.OrgsFixtures.org_fixture(user)
    membership = PetalPro.Orgs.get_membership!(user, org.slug)

    {:ok,
     conn: put_req_header(conn, "accept", "application/json"),
     user: user,
     other_user: other_user,
     admin_user: admin_user,
     org: org,
     membership: membership}
  end

  describe "list" do
    test "list organisations", %{conn: conn, user: user} do
      conn =
        conn
        |> put_bearer_token(user)
        |> get(~p"/api/user/#{user.id}/orgs")

      assert orgs = json_response(conn, 200)
      assert Enum.count(orgs) > 0
    end

    test "can't list organisations for other user", %{
      conn: conn,
      user: user,
      other_user: other_user
    } do
      conn =
        conn
        |> put_bearer_token(user)
        |> get(~p"/api/user/#{other_user.id}/orgs")

      assert json_response(conn, 403)
    end

    test "admin can list organisations for other user", %{
      conn: conn,
      admin_user: admin_user,
      other_user: other_user
    } do
      conn =
        conn
        |> put_bearer_token(admin_user)
        |> get(~p"/api/user/#{other_user.id}")

      assert json_response(conn, 200)
    end
  end
end
