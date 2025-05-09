defmodule CodeHorizonWeb.ProgressLiveTest do
  use CodeHorizonWeb.ConnCase

  import CodeHorizon.ProgressTrackingFixtures
  import Phoenix.LiveViewTest

  @create_attrs %{
    completion_status: :not_started,
    percent_complete: 42,
    last_accessed_at: "2025-05-07T20:39:00Z",
    completion_date: "2025-05-07T20:39:00Z"
  }
  @update_attrs %{
    completion_status: :in_progress,
    percent_complete: 43,
    last_accessed_at: "2025-05-08T20:39:00Z",
    completion_date: "2025-05-08T20:39:00Z"
  }
  @invalid_attrs %{completion_status: nil, percent_complete: nil, last_accessed_at: nil, completion_date: nil}

  defp create_progress(_) do
    progress = progress_fixture()
    %{progress: progress}
  end

  describe "Index" do
    setup [:create_progress]

    test "lists all progress", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/app/progress")

      assert html =~ "Listing Progress"
    end

    test "saves new progress", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/app/progress")

      assert index_live |> element("a", "New Progress") |> render_click() =~
               "New Progress"

      assert_patch(index_live, ~p"/app/progress/new")

      assert index_live
             |> form("#progress-form", progress: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#progress-form", progress: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/app/progress")

      assert html =~ "Progress created successfully"
    end

    test "updates progress in listing", %{conn: conn, progress: progress} do
      {:ok, index_live, _html} = live(conn, ~p"/app/progress")

      assert index_live |> element("a[href='/progress/#{progress.id}/edit']", "Edit") |> render_click() =~
               "Edit Progress"

      assert_patch(index_live, ~p"/app/progress/#{progress}/edit")

      assert index_live
             |> form("#progress-form", progress: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#progress-form", progress: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/app/progress")

      assert html =~ "Progress updated successfully"
    end

    test "deletes progress in listing", %{conn: conn, progress: progress} do
      {:ok, index_live, _html} = live(conn, ~p"/app/progress")

      assert index_live |> element("a[phx-value-id=#{progress.id}]", "Delete") |> render_click()
      refute has_element?(index_live, "a[phx-value-id=#{progress.id}]")
    end
  end

  describe "Show" do
    setup [:create_progress]

    test "displays progress", %{conn: conn, progress: progress} do
      {:ok, _show_live, html} = live(conn, ~p"/app/progress/#{progress}")

      assert html =~ "Show Progress"
    end

    test "updates progress within modal", %{conn: conn, progress: progress} do
      {:ok, show_live, _html} = live(conn, ~p"/app/progress/#{progress}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Progress"

      assert_patch(show_live, ~p"/app/progress/#{progress}/show/edit")

      assert show_live
             |> form("#progress-form", progress: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#progress-form", progress: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/app/progress/#{progress}")

      assert html =~ "Progress updated successfully"
    end
  end
end
