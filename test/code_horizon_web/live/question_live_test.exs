defmodule CodeHorizonWeb.QuestionLiveTest do
  use CodeHorizonWeb.ConnCase

  import CodeHorizon.AssessmentsFixtures
  import Phoenix.LiveViewTest

  @create_attrs %{order: 42, question_text: "some question_text", question_type: :multiple_choice, points: 42}
  @update_attrs %{order: 43, question_text: "some updated question_text", question_type: :single_choice, points: 43}
  @invalid_attrs %{order: nil, question_text: nil, question_type: nil, points: nil}

  defp create_question(_) do
    question = question_fixture()
    %{question: question}
  end

  describe "Index" do
    setup [:create_question]

    test "lists all questions", %{conn: conn, question: question} do
      {:ok, _index_live, html} = live(conn, ~p"/app/questions")

      assert html =~ "Listing Questions"
      assert html =~ question.question_text
    end

    test "saves new question", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/app/questions")

      assert index_live |> element("a", "New Question") |> render_click() =~
               "New Question"

      assert_patch(index_live, ~p"/app/questions/new")

      assert index_live
             |> form("#question-form", question: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#question-form", question: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/app/questions")

      assert html =~ "Question created successfully"
      assert html =~ "some question_text"
    end

    test "updates question in listing", %{conn: conn, question: question} do
      {:ok, index_live, _html} = live(conn, ~p"/app/questions")

      assert index_live |> element("a[href='/questions/#{question.id}/edit']", "Edit") |> render_click() =~
               "Edit Question"

      assert_patch(index_live, ~p"/app/questions/#{question}/edit")

      assert index_live
             |> form("#question-form", question: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#question-form", question: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/app/questions")

      assert html =~ "Question updated successfully"
      assert html =~ "some updated question_text"
    end

    test "deletes question in listing", %{conn: conn, question: question} do
      {:ok, index_live, _html} = live(conn, ~p"/app/questions")

      assert index_live |> element("a[phx-value-id=#{question.id}]", "Delete") |> render_click()
      refute has_element?(index_live, "a[phx-value-id=#{question.id}]")
    end
  end

  describe "Show" do
    setup [:create_question]

    test "displays question", %{conn: conn, question: question} do
      {:ok, _show_live, html} = live(conn, ~p"/app/questions/#{question}")

      assert html =~ "Show Question"
      assert html =~ question.question_text
    end

    test "updates question within modal", %{conn: conn, question: question} do
      {:ok, show_live, _html} = live(conn, ~p"/app/questions/#{question}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Question"

      assert_patch(show_live, ~p"/app/questions/#{question}/show/edit")

      assert show_live
             |> form("#question-form", question: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#question-form", question: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/app/questions/#{question}")

      assert html =~ "Question updated successfully"
      assert html =~ "some updated question_text"
    end
  end
end
