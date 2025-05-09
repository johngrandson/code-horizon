defmodule CodeHorizonWeb.StudentDashboardLiveTest do
  use CodeHorizonWeb.ConnCase

  import CodeHorizon.StudentsFixtures
  import Phoenix.LiveViewTest

  @create_attrs %{}
  @update_attrs %{}
  @invalid_attrs %{}

  defp create_student_dashboard(_) do
    student_dashboard = student_dashboard_fixture()
    %{student_dashboard: student_dashboard}
  end

  describe "Index" do
    setup [:create_student_dashboard]

    test "lists all student_dashboards", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/app/student_dashboards")

      assert html =~ "Listing Student dashboards"
    end

    test "saves new student_dashboard", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/app/student_dashboards")

      assert index_live |> element("a", "New Student dashboard") |> render_click() =~
               "New Student dashboard"

      assert_patch(index_live, ~p"/app/student_dashboards/new")

      assert index_live
             |> form("#student_dashboard-form", student_dashboard: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#student_dashboard-form", student_dashboard: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/app/student_dashboards")

      html = render(index_live)
      assert html =~ "Student dashboard created successfully"
    end

    test "updates student_dashboard in listing", %{conn: conn, student_dashboard: student_dashboard} do
      {:ok, index_live, _html} = live(conn, ~p"/app/student_dashboards")

      assert index_live |> element("a[href='/student_dashboards/#{student_dashboard.id}/edit']", "Edit") |> render_click() =~
               "Edit Student dashboard"

      assert_patch(index_live, ~p"/app/student_dashboards/#{student_dashboard}/edit")

      assert index_live
             |> form("#student_dashboard-form", student_dashboard: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#student_dashboard-form", student_dashboard: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/app/student_dashboards")

      html = render(index_live)
      assert html =~ "Student dashboard updated successfully"
    end

    test "deletes student_dashboard in listing", %{conn: conn, student_dashboard: student_dashboard} do
      {:ok, index_live, _html} = live(conn, ~p"/app/student_dashboards")

      assert index_live |> element("#student_dashboards-#{student_dashboard.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "a[phx-value-id=#{student_dashboard.id}]")
    end
  end

  describe "Show" do
    setup [:create_student_dashboard]

    test "displays student_dashboard", %{conn: conn, student_dashboard: student_dashboard} do
      {:ok, _show_live, html} = live(conn, ~p"/app/student_dashboards/#{student_dashboard}")

      assert html =~ "Show Student dashboard"
    end

    test "updates student_dashboard within modal", %{conn: conn, student_dashboard: student_dashboard} do
      {:ok, show_live, _html} = live(conn, ~p"/app/student_dashboards/#{student_dashboard}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Student dashboard"

      assert_patch(show_live, ~p"/app/student_dashboards/#{student_dashboard}/show/edit")

      assert show_live
             |> form("#student_dashboard-form", student_dashboard: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#student_dashboard-form", student_dashboard: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/app/student_dashboards/#{student_dashboard}")

      html = render(show_live)
      assert html =~ "Student dashboard updated successfully"
    end
  end
end
