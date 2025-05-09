defmodule CodeHorizonWeb.QuestionOptionLiveTest do
  use CodeHorizonWeb.ConnCase

  import CodeHorizon.AssessmentsFixtures
  import Phoenix.LiveViewTest

  @create_attrs %{order: 42, option_text: "some option_text", is_correct: true}
  @update_attrs %{order: 43, option_text: "some updated option_text", is_correct: false}
  @invalid_attrs %{order: nil, option_text: nil, is_correct: false}

  defp create_question_option(_) do
    question_option = question_option_fixture()
    %{question_option: question_option}
  end

  describe "Index" do
    setup [:create_question_option]

    test "lists all question_options", %{conn: conn, question_option: question_option} do
      {:ok, _index_live, html} = live(conn, ~p"/app/question_options")

      assert html =~ "Listing Question options"
      assert html =~ question_option.option_text
    end

    test "saves new question_option", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/app/question_options")

      assert index_live |> element("a", "New Question option") |> render_click() =~
               "New Question option"

      assert_patch(index_live, ~p"/app/question_options/new")

      assert index_live
             |> form("#question_option-form", question_option: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#question_option-form", question_option: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/app/question_options")

      assert html =~ "Question option created successfully"
      assert html =~ "some option_text"
    end

    test "updates question_option in listing", %{conn: conn, question_option: question_option} do
      {:ok, index_live, _html} = live(conn, ~p"/app/question_options")

      assert index_live |> element("a[href='/question_options/#{question_option.id}/edit']", "Edit") |> render_click() =~
               "Edit Question option"

      assert_patch(index_live, ~p"/app/question_options/#{question_option}/edit")

      assert index_live
             |> form("#question_option-form", question_option: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#question_option-form", question_option: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/app/question_options")

      assert html =~ "Question option updated successfully"
      assert html =~ "some updated option_text"
    end

    test "deletes question_option in listing", %{conn: conn, question_option: question_option} do
      {:ok, index_live, _html} = live(conn, ~p"/app/question_options")

      assert index_live |> element("a[phx-value-id=#{question_option.id}]", "Delete") |> render_click()
      refute has_element?(index_live, "a[phx-value-id=#{question_option.id}]")
    end
  end

  describe "Show" do
    setup [:create_question_option]

    test "displays question_option", %{conn: conn, question_option: question_option} do
      {:ok, _show_live, html} = live(conn, ~p"/app/question_options/#{question_option}")

      assert html =~ "Show Question option"
      assert html =~ question_option.option_text
    end

    test "updates question_option within modal", %{conn: conn, question_option: question_option} do
      {:ok, show_live, _html} = live(conn, ~p"/app/question_options/#{question_option}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Question option"

      assert_patch(show_live, ~p"/app/question_options/#{question_option}/show/edit")

      assert show_live
             |> form("#question_option-form", question_option: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#question_option-form", question_option: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/app/question_options/#{question_option}")

      assert html =~ "Question option updated successfully"
      assert html =~ "some updated option_text"
    end
  end
end
