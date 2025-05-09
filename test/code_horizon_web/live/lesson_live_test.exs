defmodule CodeHorizonWeb.LessonLiveTest do
  use CodeHorizonWeb.ConnCase

  import CodeHorizon.LessonsFixtures
  import Phoenix.LiveViewTest

  @create_attrs %{title: "some title", content: "some content", order: 42}
  @update_attrs %{title: "some updated title", content: "some updated content", order: 43}
  @invalid_attrs %{title: nil, content: nil, order: nil}

  defp create_lesson(_) do
    lesson = lesson_fixture()
    %{lesson: lesson}
  end

  describe "Index" do
    setup [:create_lesson]

    test "lists all lessons", %{conn: conn, lesson: lesson} do
      {:ok, _index_live, html} = live(conn, ~p"/app/lessons")

      assert html =~ "Listing Lessons"
      assert html =~ lesson.title
    end

    test "saves new lesson", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/app/lessons")

      assert index_live |> element("a", "New Lesson") |> render_click() =~
               "New Lesson"

      assert_patch(index_live, ~p"/app/lessons/new")

      assert index_live
             |> form("#lesson-form", lesson: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#lesson-form", lesson: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/app/lessons")

      assert html =~ "Lesson created successfully"
      assert html =~ "some title"
    end

    test "updates lesson in listing", %{conn: conn, lesson: lesson} do
      {:ok, index_live, _html} = live(conn, ~p"/app/lessons")

      assert index_live |> element("a[href='/lessons/#{lesson.id}/edit']", "Edit") |> render_click() =~
               "Edit Lesson"

      assert_patch(index_live, ~p"/app/lessons/#{lesson}/edit")

      assert index_live
             |> form("#lesson-form", lesson: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#lesson-form", lesson: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/app/lessons")

      assert html =~ "Lesson updated successfully"
      assert html =~ "some updated title"
    end

    test "deletes lesson in listing", %{conn: conn, lesson: lesson} do
      {:ok, index_live, _html} = live(conn, ~p"/app/lessons")

      assert index_live |> element("a[phx-value-id=#{lesson.id}]", "Delete") |> render_click()
      refute has_element?(index_live, "a[phx-value-id=#{lesson.id}]")
    end
  end

  describe "Show" do
    setup [:create_lesson]

    test "displays lesson", %{conn: conn, lesson: lesson} do
      {:ok, _show_live, html} = live(conn, ~p"/app/lessons/#{lesson}")

      assert html =~ "Show Lesson"
      assert html =~ lesson.title
    end

    test "updates lesson within modal", %{conn: conn, lesson: lesson} do
      {:ok, show_live, _html} = live(conn, ~p"/app/lessons/#{lesson}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Lesson"

      assert_patch(show_live, ~p"/app/lessons/#{lesson}/show/edit")

      assert show_live
             |> form("#lesson-form", lesson: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#lesson-form", lesson: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/app/lessons/#{lesson}")

      assert html =~ "Lesson updated successfully"
      assert html =~ "some updated title"
    end
  end
end
