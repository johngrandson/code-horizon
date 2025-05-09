defmodule CodeHorizonWeb.CourseLiveTest do
  use CodeHorizonWeb.ConnCase

  import CodeHorizon.CoursesFixtures
  import Phoenix.LiveViewTest

  @create_attrs %{
    level: :beginner,
    description: "some description",
    title: "some title",
    is_published: true,
    featured_order: 42,
    slug: "some slug"
  }
  @update_attrs %{
    level: :intermediate,
    description: "some updated description",
    title: "some updated title",
    is_published: false,
    featured_order: 43,
    slug: "some updated slug"
  }
  @invalid_attrs %{level: nil, description: nil, title: nil, is_published: false, featured_order: nil, slug: nil}

  defp create_course(_) do
    course = course_fixture()
    %{course: course}
  end

  describe "Index" do
    setup [:create_course]

    test "lists all courses", %{conn: conn, course: course} do
      {:ok, _index_live, html} = live(conn, ~p"/app/courses")

      assert html =~ "Listing Courses"
      assert html =~ course.description
    end

    test "saves new course", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/app/courses")

      assert index_live |> element("a", "New Course") |> render_click() =~
               "New Course"

      assert_patch(index_live, ~p"/app/courses/new")

      assert index_live
             |> form("#course-form", course: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#course-form", course: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/app/courses")

      assert html =~ "Course created successfully"
      assert html =~ "some description"
    end

    test "updates course in listing", %{conn: conn, course: course} do
      {:ok, index_live, _html} = live(conn, ~p"/app/courses")

      assert index_live |> element("a[href='/courses/#{course.id}/edit']", "Edit") |> render_click() =~
               "Edit Course"

      assert_patch(index_live, ~p"/app/courses/#{course}/edit")

      assert index_live
             |> form("#course-form", course: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#course-form", course: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/app/courses")

      assert html =~ "Course updated successfully"
      assert html =~ "some updated description"
    end

    test "deletes course in listing", %{conn: conn, course: course} do
      {:ok, index_live, _html} = live(conn, ~p"/app/courses")

      assert index_live |> element("a[phx-value-id=#{course.id}]", "Delete") |> render_click()
      refute has_element?(index_live, "a[phx-value-id=#{course.id}]")
    end
  end

  describe "Show" do
    setup [:create_course]

    test "displays course", %{conn: conn, course: course} do
      {:ok, _show_live, html} = live(conn, ~p"/app/courses/#{course}")

      assert html =~ "Show Course"
      assert html =~ course.description
    end

    test "updates course within modal", %{conn: conn, course: course} do
      {:ok, show_live, _html} = live(conn, ~p"/app/courses/#{course}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Course"

      assert_patch(show_live, ~p"/app/courses/#{course}/show/edit")

      assert show_live
             |> form("#course-form", course: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#course-form", course: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/app/courses/#{course}")

      assert html =~ "Course updated successfully"
      assert html =~ "some updated description"
    end
  end
end
