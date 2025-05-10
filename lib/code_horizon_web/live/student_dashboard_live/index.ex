defmodule CodeHorizonWeb.StudentDashboardLive.Index do
  @moduledoc """
  LiveView for the student dashboard that displays learning statistics,
  enrolled courses, upcoming assessments, recent activity and recommended courses.
  """
  use CodeHorizonWeb, :live_view

  alias CodeHorizon.Students

  @impl true
  def mount(_params, _session, socket) do
    student_id = socket.assigns.current_user.id
    dashboard_data = Students.get_student_dashboard!(student_id)

    {:ok,
     socket
     |> assign(:page_title, "Student Dashboard")
     |> assign_dashboard_data(dashboard_data)}
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

  # Helper functions for activity display

  defp activity_message(activity) do
    case activity.type do
      :course_enrolled -> "Enrolled in a new course"
      :course_completed -> "Completed a course"
      :assessment_submitted -> "Submitted an assessment"
      :assessment_completed -> "Completed an assessment"
      :lesson_completed -> "Completed a lesson"
      _ -> "Performed an activity"
    end
  end

  # Helper functions for display

  defp format_count(count) when is_integer(count) do
    cond do
      count >= 1_000_000 -> "#{Float.round(count / 1_000_000, 1)}M"
      count >= 1_000 -> "#{Float.round(count / 1_000, 1)}K"
      true -> to_string(count)
    end
  end

  defp format_count(_), do: "0"

  defp relative_time(timestamp) do
    now = NaiveDateTime.utc_now()
    diff_seconds = NaiveDateTime.diff(now, timestamp, :second)

    cond do
      diff_seconds < 60 -> "just now"
      diff_seconds < 60 * 60 -> "#{div(diff_seconds, 60)} minutes ago"
      diff_seconds < 60 * 60 * 24 -> "#{div(diff_seconds, 60 * 60)} hours ago"
      diff_seconds < 60 * 60 * 24 * 7 -> "#{div(diff_seconds, 60 * 60 * 24)} days ago"
      diff_seconds < 60 * 60 * 24 * 30 -> "#{div(diff_seconds, 60 * 60 * 24 * 7)} weeks ago"
      true -> format_datetime(timestamp)
    end
  end

  defp assessment_badge_color(type) do
    case type do
      :quiz -> "info"
      :exam -> "warning"
      :assignment -> "success"
      _ -> "secondary"
    end
  end

  defp humanize_assessment_type(type) do
    type
    |> to_string()
    |> String.capitalize()
  end

  defp due_date_class(due_date) do
    days_until = Date.diff(due_date, Date.utc_today())

    cond do
      days_until < 0 -> "text-red-500"
      days_until <= 3 -> "text-amber-500"
      true -> "text-gray-500"
    end
  end

  defp dark_due_date_class(due_date) do
    days_until = Date.diff(due_date, Date.utc_today())

    cond do
      days_until < 0 -> "text-red-400"
      days_until <= 3 -> "text-amber-400"
      true -> "text-gray-400"
    end
  end

  defp format_datetime(datetime) do
    Calendar.strftime(datetime, "%b %d, %Y at %H:%M")
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

  # Helper function to generate a lighter version of the activity icon color for gradient
  def activity_icon_color_lighter(type) do
    base_color = activity_color_for_icon(type)

    # Create a lighter version with orange theme
    case base_color do
      # orange-600
      # orange-500
      "#EA580C" -> "#F97316"
      # orange-700
      # orange-600
      "#C2410C" -> "#EA580C"
      # orange-800
      # orange-700
      "#9A3412" -> "#C2410C"
      # orange-900
      # orange-800
      "#7C2D12" -> "#9A3412"
      # default - orange-400
      _ -> "#FB923C"
    end
  end

  # Returns the base color for each activity type
  defp activity_color_for_icon(type) do
    case type do
      # orange-600
      :course_enrolled -> "#EA580C"
      :course_started -> "#EA580C"
      # orange-700
      :course_completed -> "#C2410C"
      # orange-800
      :assessment_submitted -> "#9A3412"
      :assessment_completed -> "#9A3412"
      # orange-700
      :lesson_completed -> "#C2410C"
      # orange-500
      _ -> "#F97316"
    end
  end

  # Helper function to determine score color class based on score value
  defp score_color_class(score) when is_number(score) do
    cond do
      score >= 90 -> "bg-green-100 dark:bg-green-900/40 text-green-700 dark:text-green-400"
      score >= 70 -> "bg-orange-100 dark:bg-orange-900/40 text-orange-700 dark:text-orange-400"
      score >= 50 -> "bg-amber-100 dark:bg-amber-900/40 text-amber-700 dark:text-amber-400"
      true -> "bg-red-100 dark:bg-red-900/40 text-red-700 dark:text-red-400"
    end
  end

  defp score_color_class(_), do: "bg-gray-100 dark:bg-gray-800 text-gray-700 dark:text-gray-400"
end
