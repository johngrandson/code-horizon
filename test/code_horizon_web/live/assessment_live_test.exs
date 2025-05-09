defmodule CodeHorizonWeb.AssessmentLiveTest do
  use CodeHorizonWeb.ConnCase

  import CodeHorizon.AssessmentsFixtures
  import Phoenix.LiveViewTest

  @create_attrs %{
    max_attempts: 42,
    description: "some description",
    title: "some title",
    passing_score: 42,
    time_limit_minutes: 42,
    assessment_type: :quiz,
    is_published: true
  }
  @update_attrs %{
    max_attempts: 43,
    description: "some updated description",
    title: "some updated title",
    passing_score: 43,
    time_limit_minutes: 43,
    assessment_type: :assignment,
    is_published: false
  }
  @invalid_attrs %{
    max_attempts: nil,
    description: nil,
    title: nil,
    passing_score: nil,
    time_limit_minutes: nil,
    assessment_type: nil,
    is_published: false
  }

  defp create_assessment(_) do
    assessment = assessment_fixture()
    %{assessment: assessment}
  end

  describe "Index" do
    setup [:create_assessment]

    test "lists all assessments", %{conn: conn, assessment: assessment} do
      {:ok, _index_live, html} = live(conn, ~p"/app/assessments")

      assert html =~ "Listing Assessments"
      assert html =~ assessment.description
    end

    test "saves new assessment", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/app/assessments")

      assert index_live |> element("a", "New Assessment") |> render_click() =~
               "New Assessment"

      assert_patch(index_live, ~p"/app/assessments/new")

      assert index_live
             |> form("#assessment-form", assessment: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#assessment-form", assessment: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/app/assessments")

      assert html =~ "Assessment created successfully"
      assert html =~ "some description"
    end

    test "updates assessment in listing", %{conn: conn, assessment: assessment} do
      {:ok, index_live, _html} = live(conn, ~p"/app/assessments")

      assert index_live |> element("a[href='/assessments/#{assessment.id}/edit']", "Edit") |> render_click() =~
               "Edit Assessment"

      assert_patch(index_live, ~p"/app/assessments/#{assessment}/edit")

      assert index_live
             |> form("#assessment-form", assessment: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#assessment-form", assessment: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/app/assessments")

      assert html =~ "Assessment updated successfully"
      assert html =~ "some updated description"
    end

    test "deletes assessment in listing", %{conn: conn, assessment: assessment} do
      {:ok, index_live, _html} = live(conn, ~p"/app/assessments")

      assert index_live |> element("a[phx-value-id=#{assessment.id}]", "Delete") |> render_click()
      refute has_element?(index_live, "a[phx-value-id=#{assessment.id}]")
    end
  end

  describe "Show" do
    setup [:create_assessment]

    test "displays assessment", %{conn: conn, assessment: assessment} do
      {:ok, _show_live, html} = live(conn, ~p"/app/assessments/#{assessment}")

      assert html =~ "Show Assessment"
      assert html =~ assessment.description
    end

    test "updates assessment within modal", %{conn: conn, assessment: assessment} do
      {:ok, show_live, _html} = live(conn, ~p"/app/assessments/#{assessment}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Assessment"

      assert_patch(show_live, ~p"/app/assessments/#{assessment}/show/edit")

      assert show_live
             |> form("#assessment-form", assessment: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#assessment-form", assessment: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/app/assessments/#{assessment}")

      assert html =~ "Assessment updated successfully"
      assert html =~ "some updated description"
    end
  end
end
