defmodule CodeHorizonWeb.AssessmentAttemptLiveTest do
  use CodeHorizonWeb.ConnCase

  import CodeHorizon.AssessmentsFixtures
  import Phoenix.LiveViewTest

  @create_attrs %{status: :in_progress, score: 42, start_time: "2025-05-07T20:56:00Z", end_time: "2025-05-07T20:56:00Z"}
  @update_attrs %{status: :submitted, score: 43, start_time: "2025-05-08T20:56:00Z", end_time: "2025-05-08T20:56:00Z"}
  @invalid_attrs %{status: nil, score: nil, start_time: nil, end_time: nil}

  defp create_assessment_attempt(_) do
    assessment_attempt = assessment_attempt_fixture()
    %{assessment_attempt: assessment_attempt}
  end

  describe "Index" do
    setup [:create_assessment_attempt]

    test "lists all assessment_attempts", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/app/assessment_attempts")

      assert html =~ "Listing Assessment attempts"
    end

    test "saves new assessment_attempt", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/app/assessment_attempts")

      assert index_live |> element("a", "New Assessment attempt") |> render_click() =~
               "New Assessment attempt"

      assert_patch(index_live, ~p"/app/assessment_attempts/new")

      assert index_live
             |> form("#assessment_attempt-form", assessment_attempt: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#assessment_attempt-form", assessment_attempt: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/app/assessment_attempts")

      assert html =~ "Assessment attempt created successfully"
    end

    test "updates assessment_attempt in listing", %{conn: conn, assessment_attempt: assessment_attempt} do
      {:ok, index_live, _html} = live(conn, ~p"/app/assessment_attempts")

      assert index_live
             |> element("a[href='/assessment_attempts/#{assessment_attempt.id}/edit']", "Edit")
             |> render_click() =~
               "Edit Assessment attempt"

      assert_patch(index_live, ~p"/app/assessment_attempts/#{assessment_attempt}/edit")

      assert index_live
             |> form("#assessment_attempt-form", assessment_attempt: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#assessment_attempt-form", assessment_attempt: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/app/assessment_attempts")

      assert html =~ "Assessment attempt updated successfully"
    end

    test "deletes assessment_attempt in listing", %{conn: conn, assessment_attempt: assessment_attempt} do
      {:ok, index_live, _html} = live(conn, ~p"/app/assessment_attempts")

      assert index_live |> element("a[phx-value-id=#{assessment_attempt.id}]", "Delete") |> render_click()
      refute has_element?(index_live, "a[phx-value-id=#{assessment_attempt.id}]")
    end
  end

  describe "Show" do
    setup [:create_assessment_attempt]

    test "displays assessment_attempt", %{conn: conn, assessment_attempt: assessment_attempt} do
      {:ok, _show_live, html} = live(conn, ~p"/app/assessment_attempts/#{assessment_attempt}")

      assert html =~ "Show Assessment attempt"
    end

    test "updates assessment_attempt within modal", %{conn: conn, assessment_attempt: assessment_attempt} do
      {:ok, show_live, _html} = live(conn, ~p"/app/assessment_attempts/#{assessment_attempt}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Assessment attempt"

      assert_patch(show_live, ~p"/app/assessment_attempts/#{assessment_attempt}/show/edit")

      assert show_live
             |> form("#assessment_attempt-form", assessment_attempt: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#assessment_attempt-form", assessment_attempt: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/app/assessment_attempts/#{assessment_attempt}")

      assert html =~ "Assessment attempt updated successfully"
    end
  end
end
