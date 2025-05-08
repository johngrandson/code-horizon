defmodule CodeHorizonWeb.DashboardLiveTest do
  use CodeHorizonWeb.ConnCase

  import Phoenix.LiveViewTest

  setup :register_and_sign_in_user

  test "renders the user's name", %{conn: conn, user: user} do
    {:ok, _view, html} = live(conn, ~p"/app")
    assert html =~ user.name
  end
end
