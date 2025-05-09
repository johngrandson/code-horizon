defmodule CodeHorizonWeb.EnrollmentLiveTest do
  use CodeHorizonWeb.ConnCase

  import CodeHorizon.EnrollmentsFixtures
  import Phoenix.LiveViewTest

  @create_attrs %{status: :active, enrolled_at: "2025-05-07T20:32:00Z", expires_at: "2025-05-07T20:32:00Z"}
  @update_attrs %{status: :completed, enrolled_at: "2025-05-08T20:32:00Z", expires_at: "2025-05-08T20:32:00Z"}
  @invalid_attrs %{status: nil, enrolled_at: nil, expires_at: nil}

  defp create_enrollment(_) do
    enrollment = enrollment_fixture()
    %{enrollment: enrollment}
  end

  describe "Index" do
    setup [:create_enrollment]

    test "lists all enrollments", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/app/enrollments")

      assert html =~ "Listing Enrollments"
    end

    test "saves new enrollment", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/app/enrollments")

      assert index_live |> element("a", "New Enrollment") |> render_click() =~
               "New Enrollment"

      assert_patch(index_live, ~p"/app/enrollments/new")

      assert index_live
             |> form("#enrollment-form", enrollment: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#enrollment-form", enrollment: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/app/enrollments")

      assert html =~ "Enrollment created successfully"
    end

    test "updates enrollment in listing", %{conn: conn, enrollment: enrollment} do
      {:ok, index_live, _html} = live(conn, ~p"/app/enrollments")

      assert index_live |> element("a[href='/enrollments/#{enrollment.id}/edit']", "Edit") |> render_click() =~
               "Edit Enrollment"

      assert_patch(index_live, ~p"/app/enrollments/#{enrollment}/edit")

      assert index_live
             |> form("#enrollment-form", enrollment: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#enrollment-form", enrollment: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/app/enrollments")

      assert html =~ "Enrollment updated successfully"
    end

    test "deletes enrollment in listing", %{conn: conn, enrollment: enrollment} do
      {:ok, index_live, _html} = live(conn, ~p"/app/enrollments")

      assert index_live |> element("a[phx-value-id=#{enrollment.id}]", "Delete") |> render_click()
      refute has_element?(index_live, "a[phx-value-id=#{enrollment.id}]")
    end
  end

  describe "Show" do
    setup [:create_enrollment]

    test "displays enrollment", %{conn: conn, enrollment: enrollment} do
      {:ok, _show_live, html} = live(conn, ~p"/app/enrollments/#{enrollment}")

      assert html =~ "Show Enrollment"
    end

    test "updates enrollment within modal", %{conn: conn, enrollment: enrollment} do
      {:ok, show_live, _html} = live(conn, ~p"/app/enrollments/#{enrollment}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Enrollment"

      assert_patch(show_live, ~p"/app/enrollments/#{enrollment}/show/edit")

      assert show_live
             |> form("#enrollment-form", enrollment: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#enrollment-form", enrollment: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/app/enrollments/#{enrollment}")

      assert html =~ "Enrollment updated successfully"
    end
  end
end
