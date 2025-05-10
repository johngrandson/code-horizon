defmodule CodeHorizonWeb.StudentDashboardLive.Index do
  @moduledoc """
  LiveView for the student dashboard that displays learning statistics,
  enrolled courses, upcoming assessments, recent activity and recommended courses.
  """
  use CodeHorizonWeb, :live_view

  import CodeHorizonWeb.FeatureCards
  import CodeHorizonWeb.LMSComponents.ActivityComponents
  import CodeHorizonWeb.LMSComponents.CourseComponents
  import CodeHorizonWeb.Util.CSSForComponent

  alias CodeHorizon.Students

  @dashboard_css load_css("lms_dashboard.css")

  @impl true
  def mount(_params, _session, socket) do
    student_id = socket.assigns.current_user.id
    dashboard_data = Students.get_student_dashboard!(student_id)

    {featured_courses, regular_courses} = Enum.split(dashboard_data.recommended_courses, 2)

    {:ok,
     socket
     |> assign_dashboard_data(dashboard_data)
     |> assign(:page_title, "Student Dashboard")
     |> assign(:dashboard_css, @dashboard_css)
     |> stream(:featured_recommended_courses, featured_courses)
     |> stream(:regular_recommended_courses, regular_courses)}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("explore_course", %{"id" => course_id}, socket) do
    {:noreply, push_navigate(socket, to: ~p"/app/courses/#{course_id}")}
  end

  @impl true
  def handle_event("navigate_to_course", %{"id" => course_id}, socket) do
    {:noreply, push_navigate(socket, to: ~p"/app/courses/#{course_id}")}
  end

  @impl true
  def handle_event("view_assessment_details", %{"id" => assessment_id}, socket) do
    {:noreply, push_navigate(socket, to: ~p"/app/assessments/#{assessment_id}")}
  end

  @impl true
  def handle_event("view_activity_details", %{"id" => _activity_id}, socket) do
    # In a real app, this would navigate to the activity details page
    {:noreply, socket}
  end

  @impl true
  def handle_event("explore_courses", _params, socket) do
    {:noreply, push_navigate(socket, to: ~p"/app/courses")}
  end

  # Private functions

  defp assign_dashboard_data(socket, dashboard_data) do
    socket
    |> assign(:learning_stats, dashboard_data.learning_stats)
    |> assign(:enrolled_courses_count, length(dashboard_data.enrolled_courses))
    |> assign(:upcoming_assessments_count, length(dashboard_data.upcoming_assessments))
    |> assign(:recent_activity_count, length(dashboard_data.recent_activity))
    |> assign(:recommended_courses_count, length(dashboard_data.recommended_courses))
    |> stream(:enrolled_courses, dashboard_data.enrolled_courses)
    |> stream(:upcoming_assessments, dashboard_data.upcoming_assessments)
    |> stream(:recent_activity, dashboard_data.recent_activity)
    |> stream(:recommended_courses, dashboard_data.recommended_courses)
  end

  # Helper functions for stats

  defp completion_percentage(completed, total) do
    case total do
      0 -> 0
      _ -> round(completed / total * 100)
    end
  end

  defp calculate_trend(_completed) do
    # This would normally be calculated from historical data
    # For demo purposes, just generate a random trend between 5-20%
    trunc(:rand.uniform() * 15) + 5
  end

  defp activity_level(courses_in_progress) do
    # Simple helper to calculate an "activity level" from 1-5 based on in-progress courses
    min(courses_in_progress, 5)
  end

  defp random_time_ago do
    # For demo purposes - ideally this would be a real timestamp
    options = ["5 minutes ago", "2 hours ago", "today", "yesterday"]
    Enum.random(options)
  end

  # Assessment helper functions

  defp humanize_assessment_type(type) do
    type
    |> to_string()
    |> String.capitalize()
  end

  # Progress status helpers

  defp progress_color_class(progress, is_text \\ false) do
    prefix = if is_text, do: "text", else: "bg"

    cond do
      progress >= 80 -> "#{prefix}-green-600 dark:#{prefix}-green-400"
      progress >= 60 -> "#{prefix}-[color:var(--color-primary-600)] dark:#{prefix}-[color:var(--color-primary-400)]"
      progress >= 40 -> "#{prefix}-blue-600 dark:#{prefix}-blue-400"
      progress >= 20 -> "#{prefix}-amber-600 dark:#{prefix}-amber-400"
      true -> "#{prefix}-yellow-600 dark:#{prefix}-yellow-400"
    end
  end

  defp progress_status(avg_progress) when avg_progress >= 80, do: "Excellent!"
  defp progress_status(avg_progress) when avg_progress >= 60, do: "Good progress"
  defp progress_status(avg_progress) when avg_progress >= 40, do: "On track"
  defp progress_status(avg_progress) when avg_progress >= 20, do: "Getting started"
  defp progress_status(_), do: "Just beginning"

  defp progress_message(avg_progress) when avg_progress >= 80, do: "You're almost there!"
  defp progress_message(avg_progress) when avg_progress >= 60, do: "Keep up the good work"
  defp progress_message(avg_progress) when avg_progress >= 40, do: "Steady progress"
  defp progress_message(avg_progress) when avg_progress >= 20, do: "Moving forward"
  defp progress_message(_), do: "Start your journey"

  defp get_assessment_icon(type) do
    case type do
      :quiz -> "hero-clipboard-document-list"
      :exam -> "hero-document-check"
      :assignment -> "hero-document-text"
      _ -> "hero-clipboard"
    end
  end

  defp calendar_due_text(due_date, days_until) do
    cond do
      days_until == nil -> "Unknown"
      days_until < 0 -> "Overdue! (#{Calendar.strftime(due_date, "%b %d")})"
      days_until == 0 -> "Today!"
      days_until == 1 -> "Tomorrow!"
      days_until < 7 -> "In #{days_until} days"
      true -> Calendar.strftime(due_date, "%b %d, %Y")
    end
  end

  defp due_date_class(due_date) do
    days_until = if due_date, do: Date.diff(due_date, Date.utc_today())

    cond do
      days_until == nil -> ""
      days_until < 0 -> "text-red-600 dark:text-red-400 font-medium"
      days_until == 0 -> "text-amber-600 dark:text-amber-400 font-medium"
      days_until <= 3 -> "text-amber-500 dark:text-amber-400"
      true -> "text-gray-500 dark:text-gray-400"
    end
  end
end
