defmodule CodeHorizonWeb.StudentDashboardLiveTest do
  use CodeHorizonWeb.ConnCase

  import CodeHorizon.AccountsFixtures
  import CodeHorizon.StudentDashboardFixtures
  import Phoenix.LiveViewTest

  describe "Student Dashboard" do
    setup do
      user = user_fixture()

      student_id = user.id
      student_dashboard = dashboard_fixture(student_id)

      %{
        user: user,
        student_dashboard: student_dashboard,
        conn: log_in_user(build_conn(), user)
      }
    end

    test "displays dashboard with correct sections", %{conn: conn} do
      {:ok, view, html} = live(conn, ~p"/app/student/dashboard")

      assert html =~ "Welcome back"
      assert html =~ "Learning Statistics"
      assert html =~ "My Courses"
      assert html =~ "Recent Activity"
      assert html =~ "Recommended Courses"
      assert html =~ "Upcoming Assessments"
    end

    test "displays learning statistics correctly", %{conn: conn, student_dashboard: dashboard} do
      {:ok, view, _html} = live(conn, ~p"/app/student/dashboard")

      stats = dashboard.learning_stats

      assert render(view) =~ "Completed Courses"
      assert render(view) =~ "#{stats.completed_courses}"
      assert render(view) =~ "Courses in Progress"
      assert render(view) =~ "#{stats.courses_in_progress}"
      assert render(view) =~ "Total Courses"
      assert render(view) =~ "#{stats.total_courses}"
      assert render(view) =~ "Average Progress"
      assert render(view) =~ "#{stats.avg_progress}%"
    end

    test "displays enrolled courses correctly", %{conn: conn, student_dashboard: dashboard} do
      {:ok, view, _html} = live(conn, ~p"/app/student/dashboard")

      for course <- dashboard.enrolled_courses do
        assert render(view) =~ course.title
        assert render(view) =~ course.instructor.name
      end

      assert render(view) =~ "Course Progress"
      assert render(view) =~ "Continue"
    end

    test "displays recommended courses correctly", %{conn: conn, student_dashboard: dashboard} do
      {:ok, view, _html} = live(conn, ~p"/app/student/dashboard")

      for course <- dashboard.recommended_courses do
        assert render(view) =~ course.title
        if course.is_premium, do: assert(render(view) =~ "Premium")
        if course.is_free, do: assert(render(view) =~ "Free")
      end
    end

    test "displays upcoming assessments correctly", %{conn: conn, student_dashboard: dashboard} do
      {:ok, view, _html} = live(conn, ~p"/app/student/dashboard")

      for assessment <- dashboard.upcoming_assessments do
        assert render(view) =~ assessment.title
        assert render(view) =~ assessment.course_title
      end

      assert render(view) =~ "Due:"
      assert render(view) =~ "Start Assessment"
    end

    test "displays empty state when no enrolled courses", %{conn: conn, user: user} do
      dashboard = dashboard_fixture(user.id, %{enrolled_courses: []})

      {:ok, view, _html} = live(conn, ~p"/app/student/dashboard")

      send(view.pid, {:update_dashboard, %{dashboard | enrolled_courses: []}})

      assert render(view) =~ "No enrolled courses"
      assert render(view) =~ "Browse courses"
    end

    test "navigates to course details when clicking on a course", %{conn: conn, student_dashboard: dashboard} do
      {:ok, view, _html} = live(conn, ~p"/app/student/dashboard")

      course = hd(dashboard.enrolled_courses)

      assert view
             |> element("button", "Continue")
             |> render_click() =~ "phx-click=\"explore_course\""

      assert_push_event(view, "event_name", %{id: course.id})
    end

    test "handles theme changes correctly", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/app/student/dashboard")

      assert view
             |> element("button", "Theme")
             |> render_click()

      assert_push_event(view, "theme-change", %{theme: _})
    end
  end
end

defp log_in_user(conn, user) do
  conn
  |> Plug.Test.init_test_session(%{})
  |> Plug.Conn.assign(:current_user, user)
  |> Plug.Conn.put_session(:user_token, user.id)
end
