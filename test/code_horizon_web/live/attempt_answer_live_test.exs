defmodule CodeHorizonWeb.AttemptAnswerLiveTest do
  use CodeHorizonWeb.ConnCase

  import CodeHorizon.AssessmentsFixtures
  import Phoenix.LiveViewTest

  @create_attrs %{is_correct: true, answer_text: "some answer_text", points_awarded: 42}
  @update_attrs %{is_correct: false, answer_text: "some updated answer_text", points_awarded: 43}
  @invalid_attrs %{is_correct: false, answer_text: nil, points_awarded: nil}

  defp create_attempt_answer(_) do
    attempt_answer = attempt_answer_fixture()
    %{attempt_answer: attempt_answer}
  end

  describe "Index" do
    setup [:create_attempt_answer]

    test "lists all attempt_answers", %{conn: conn, attempt_answer: attempt_answer} do
      {:ok, _index_live, html} = live(conn, ~p"/app/attempt_answers")

      assert html =~ "Listing Attempt answers"
      assert html =~ attempt_answer.answer_text
    end

    test "saves new attempt_answer", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/app/attempt_answers")

      assert index_live |> element("a", "New Attempt answer") |> render_click() =~
               "New Attempt answer"

      assert_patch(index_live, ~p"/app/attempt_answers/new")

      assert index_live
             |> form("#attempt_answer-form", attempt_answer: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#attempt_answer-form", attempt_answer: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/app/attempt_answers")

      assert html =~ "Attempt answer created successfully"
      assert html =~ "some answer_text"
    end

    test "updates attempt_answer in listing", %{conn: conn, attempt_answer: attempt_answer} do
      {:ok, index_live, _html} = live(conn, ~p"/app/attempt_answers")

      assert index_live |> element("a[href='/attempt_answers/#{attempt_answer.id}/edit']", "Edit") |> render_click() =~
               "Edit Attempt answer"

      assert_patch(index_live, ~p"/app/attempt_answers/#{attempt_answer}/edit")

      assert index_live
             |> form("#attempt_answer-form", attempt_answer: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#attempt_answer-form", attempt_answer: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/app/attempt_answers")

      assert html =~ "Attempt answer updated successfully"
      assert html =~ "some updated answer_text"
    end

    test "deletes attempt_answer in listing", %{conn: conn, attempt_answer: attempt_answer} do
      {:ok, index_live, _html} = live(conn, ~p"/app/attempt_answers")

      assert index_live |> element("a[phx-value-id=#{attempt_answer.id}]", "Delete") |> render_click()
      refute has_element?(index_live, "a[phx-value-id=#{attempt_answer.id}]")
    end
  end

  describe "Show" do
    setup [:create_attempt_answer]

    test "displays attempt_answer", %{conn: conn, attempt_answer: attempt_answer} do
      {:ok, _show_live, html} = live(conn, ~p"/app/attempt_answers/#{attempt_answer}")

      assert html =~ "Show Attempt answer"
      assert html =~ attempt_answer.answer_text
    end

    test "updates attempt_answer within modal", %{conn: conn, attempt_answer: attempt_answer} do
      {:ok, show_live, _html} = live(conn, ~p"/app/attempt_answers/#{attempt_answer}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Attempt answer"

      assert_patch(show_live, ~p"/app/attempt_answers/#{attempt_answer}/show/edit")

      assert show_live
             |> form("#attempt_answer-form", attempt_answer: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#attempt_answer-form", attempt_answer: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/app/attempt_answers/#{attempt_answer}")

      assert html =~ "Attempt answer updated successfully"
      assert html =~ "some updated answer_text"
    end
  end
end
