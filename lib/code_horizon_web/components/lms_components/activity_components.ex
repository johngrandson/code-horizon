defmodule CodeHorizonWeb.LMSComponents.ActivityComponents do
  @moduledoc """
  Specialized components for activity-related features.
  Renders activity cards, lists, and other activity-specific UI elements.
  """
  use Phoenix.Component
  use PetalComponents

  import CodeHorizonWeb.FeatureCards

  @doc """
  Renders an activity item with consistent styling.

  ## Attributes

  * `activity` - Required map containing activity data
  * `class` - Additional CSS classes to apply
  * `rest` - Additional HTML attributes

  ## Activity Types

  - `:course_enrolled` - User enrolled in a course
  - `:course_completed` - User completed a course
  - `:lesson_completed` - User completed a lesson
  - `:assessment_completed` - User completed an assessment
  - `:assessment_submitted` - User submitted an assessment
  - `:quiz_attempt` - User attempted a quiz

  ## Examples

      <.activity_item
        activity={activity}
      />
  """
  attr :activity, :map, required: true, doc: "Activity data"
  attr :class, :string, default: "", doc: "Additional CSS classes"
  attr :rest, :global, doc: "Additional HTML attributes"

  def activity_item(assigns) do
    # Use the generic content_item with activity-specific data
    ~H"""
    <.content_item
      title={get_activity_title(@activity)}
      progress={@activity[:score]}
      badge_text={get_activity_badge(@activity)}
      badge_icon={get_activity_badge_icon(@activity)}
      metadata={build_activity_metadata(@activity)}
      phx_click={get_activity_action(@activity[:type])}
      action_text={get_activity_action_text(@activity[:type])}
      item_id={@activity.id}
      class={@class}
      {@rest}
    />
    """
  end

  @doc """
  Renders a list of activities.

  ## Attributes

  * `activities` - List of activity maps to display
  * `empty_state` - Map with title, message, and action for empty state
  * `class` - Additional CSS classes to apply

  ## Examples

      <.activity_list
        activities={@activities}
        empty_state={%{
          title: "No recent activity",
          message: "Your activities will appear here as you progress.",
          button_text: "Explore courses",
          button_path: ~p"/app/courses"
        }}
      />
  """
  attr :activities, :list, required: true, doc: "List of activities to display"
  attr :empty_state, :map, default: %{}, doc: "Empty state configuration"
  attr :class, :string, default: "", doc: "Additional CSS classes"

  def activity_list(assigns) do
    assigns =
      assign_new(assigns, :empty_state, fn ->
        %{
          title: "No Recent Activity",
          message: "Your learning activities will appear here as you progress through courses.",
          button_text: "Explore Courses",
          button_path: "/app/courses",
          button_icon: "hero-academic-cap"
        }
      end)

    ~H"""
    <div class={"space-y-4 #{@class}"}>
      <%= if Enum.empty?(@activities) do %>
        <div class="text-center py-12 px-6">
          <div class="bg-[color:var(--color-primary-50)] dark:bg-[color:var(--color-primary-900/20)] rounded-full h-20 w-20 flex items-center justify-center mx-auto mb-4 shadow-inner">
            <.icon
              name={@empty_state[:icon] || "hero-clock"}
              class="w-10 h-10 text-[color:var(--color-primary-400)] dark:text-[color:var(--color-primary-500)]"
            />
          </div>
          <h3 class="text-lg font-medium text-gray-900 dark:text-white mb-2">
            {@empty_state[:title]}
          </h3>
          <p class="text-gray-500 dark:text-gray-400 mb-6 max-w-md mx-auto">
            {@empty_state[:message]}
          </p>
          <%= if @empty_state[:button_text] && @empty_state[:button_path] do %>
            <.button
              link_type="live_redirect"
              to={@empty_state[:button_path]}
              color="primary"
              class="font-medium shadow transition-all duration-300"
            >
              <%= if @empty_state[:button_icon] do %>
                <.icon name={@empty_state[:button_icon]} class="w-4 h-4 mr-2" />
              <% end %>
              {@empty_state[:button_text]}
            </.button>
          <% end %>
        </div>
      <% else %>
        <%= for activity <- @activities do %>
          <.activity_item activity={activity} id={activity[:id] || generate_activity_id(activity)} />
        <% end %>
      <% end %>
    </div>
    """
  end

  @doc """
  Filters activities by type.

  ## Attributes

  * `activities` - List of activity maps to filter
  * `types` - List of activity types to include
  * `limit` - Maximum number of activities to return

  ## Examples

      <.activity_list
        activities={filter_activities(@all_activities, [:course_completed, :assessment_completed], 5)}
      />
  """
  def filter_activities(activities, types, limit \\ nil) do
    activities
    |> Enum.filter(fn activity ->
      activity_type = activity[:type]
      activity_type_string = if is_atom(activity_type), do: activity_type, else: String.to_atom(activity_type)
      Enum.member?(types, activity_type_string)
    end)
    |> then(fn filtered ->
      if limit, do: Enum.take(filtered, limit), else: filtered
    end)
  end

  # Helper Functions

  @doc """
  Gets the title for an activity.

  ## Examples

      iex> get_activity_title(%{course_title: "Introduction to Programming"})
      "Introduction to Programming"
  """
  def get_activity_title(activity) do
    cond do
      activity[:title] -> activity.title
      activity[:course_title] -> activity.course_title
      activity[:lesson_title] -> activity.lesson_title
      activity[:assessment_title] -> activity.assessment_title
      true -> "Activity"
    end
  end

  @doc """
  Gets the badge text for an activity based on type and score.

  ## Examples

      iex> get_activity_badge(%{type: :course_completed})
      "Completed"

      iex> get_activity_badge(%{type: :assessment_completed, score: 95})
      "Excellent!"
  """
  def get_activity_badge(activity) do
    cond do
      activity[:score] && activity.score >= 90 -> "Excellent!"
      activity[:score] && activity.score >= 75 -> "Good job!"
      activity[:score] && activity.score >= 60 -> "Passed"
      activity[:score] -> "Score: #{activity.score}%"
      activity[:type] == :course_completed || activity[:type] == "course_completed" -> "Completed"
      activity[:type] == :assessment_completed || activity[:type] == "assessment_completed" -> "Assessment"
      activity[:type] == :lesson_completed || activity[:type] == "lesson_completed" -> "Lesson"
      true -> nil
    end
  end

  @doc """
  Gets the badge icon for an activity based on type and score.

  ## Examples

      iex> get_activity_badge_icon(%{type: :course_completed})
      "hero-check-circle"

      iex> get_activity_badge_icon(%{type: :assessment_completed, score: 95})
      "hero-star"
  """
  def get_activity_badge_icon(activity) do
    cond do
      activity[:score] && activity.score >= 90 ->
        "hero-star"

      activity[:score] && activity.score >= 75 ->
        "hero-hand-thumb-up"

      activity[:score] && activity.score >= 60 ->
        "hero-check"

      activity[:score] ->
        "hero-chart-bar"

      activity[:type] == :course_completed || activity[:type] == "course_completed" ->
        "hero-check-circle"

      activity[:type] == :assessment_completed || activity[:type] == "assessment_completed" ->
        "hero-clipboard-document-check"

      activity[:type] == :lesson_completed || activity[:type] == "lesson_completed" ->
        "hero-book-open"

      true ->
        "hero-bell"
    end
  end

  @doc """
  Gets the appropriate action handler for an activity type.

  ## Examples

      iex> get_activity_action(:course_enrolled)
      "navigate_to_course"

      iex> get_activity_action(:assessment_completed)
      "view_assessment_details"
  """
  def get_activity_action(type) when is_binary(type), do: get_activity_action(String.to_atom(type))
  def get_activity_action(:course_enrolled), do: "navigate_to_course"
  def get_activity_action(:course_completed), do: "navigate_to_course"
  def get_activity_action(:lesson_completed), do: "navigate_to_course"
  def get_activity_action(:assessment_completed), do: "view_assessment_details"
  def get_activity_action(:assessment_submitted), do: "view_assessment_details"
  def get_activity_action(:quiz_attempt), do: "view_quiz_results"
  def get_activity_action(_), do: "view_activity_details"

  @doc """
  Gets the appropriate action text for an activity type.

  ## Examples

      iex> get_activity_action_text(:course_enrolled)
      "View Course"

      iex> get_activity_action_text(:assessment_completed)
      "View Results"
  """
  def get_activity_action_text(type) when is_binary(type), do: get_activity_action_text(String.to_atom(type))
  def get_activity_action_text(:course_enrolled), do: "View Course"
  def get_activity_action_text(:course_completed), do: "View Certificate"
  def get_activity_action_text(:lesson_completed), do: "Continue Course"
  def get_activity_action_text(:assessment_completed), do: "View Results"
  def get_activity_action_text(:assessment_submitted), do: "View Assessment"
  def get_activity_action_text(:quiz_attempt), do: "View Results"
  def get_activity_action_text(_), do: "View Details"

  @doc """
  Builds metadata array for an activity.

  Creates a list of metadata items with icons, text, and optional highlighting.

  ## Examples

      iex> build_activity_metadata(%{type: :course_enrolled, timestamp: ~N[2023-01-01 12:30:00]})
      [
        %{icon: "hero-academic-cap", text: "Course Enrollment", highlight: true},
        %{icon: "hero-clock", text: "Jan 01, 2023 at 12:30"}
      ]
  """
  def build_activity_metadata(activity) do
    # Get activity icon and type text
    icon = get_activity_type_icon(activity[:type])
    type_text = get_activity_type_text(activity[:type])

    # Build metadata list
    metadata = [
      %{
        icon: icon,
        text: type_text,
        highlight: true
      }
    ]

    # Add timestamp if available
    metadata =
      if activity[:timestamp] do
        metadata ++
          [
            %{
              icon: "hero-clock",
              text: format_relative_time(activity.timestamp)
            }
          ]
      else
        metadata
      end

    # Add description if available
    metadata =
      if activity[:description] do
        metadata ++
          [
            %{
              text: activity.description,
              highlight: false
            }
          ]
      else
        metadata
      end

    # Add course title if available and not already the main title
    metadata =
      if activity[:course_title] && get_activity_title(activity) != activity.course_title do
        metadata ++
          [
            %{
              icon: "hero-academic-cap",
              text: activity.course_title
            }
          ]
      else
        metadata
      end

    metadata
  end

  @doc """
  Gets the icon for an activity type.

  ## Examples

      iex> get_activity_type_icon(:course_enrolled)
      "hero-academic-cap"

      iex> get_activity_type_icon(:assessment_completed)
      "hero-clipboard-document-check"
  """
  def get_activity_type_icon(type) when is_binary(type), do: get_activity_type_icon(String.to_atom(type))
  def get_activity_type_icon(:course_enrolled), do: "hero-academic-cap"
  def get_activity_type_icon(:course_completed), do: "hero-check-circle"
  def get_activity_type_icon(:lesson_completed), do: "hero-book-open"
  def get_activity_type_icon(:assessment_completed), do: "hero-clipboard-document-check"
  def get_activity_type_icon(:assessment_submitted), do: "hero-clipboard-document-check"
  def get_activity_type_icon(:quiz_attempt), do: "hero-pencil-square"
  def get_activity_type_icon(_), do: "hero-bell"

  @doc """
  Gets a descriptive text for an activity type.

  ## Examples

      iex> get_activity_type_text(:course_enrolled)
      "Course Enrollment"

      iex> get_activity_type_text(:assessment_completed)
      "Assessment Completed"
  """
  def get_activity_type_text(type) when is_binary(type), do: get_activity_type_text(String.to_atom(type))
  def get_activity_type_text(:course_enrolled), do: "Course Enrollment"
  def get_activity_type_text(:course_completed), do: "Course Completed"
  def get_activity_type_text(:lesson_completed), do: "Lesson Completed"
  def get_activity_type_text(:assessment_completed), do: "Assessment Completed"
  def get_activity_type_text(:assessment_submitted), do: "Assessment Submitted"
  def get_activity_type_text(:quiz_attempt), do: "Quiz Attempt"
  def get_activity_type_text(type) when is_atom(type), do: String.capitalize(to_string(type))
  def get_activity_type_text(type) when is_binary(type), do: String.capitalize(type)
  def get_activity_type_text(_), do: "Activity"

  # Helper function to format relative time
  defp format_relative_time(%NaiveDateTime{} = timestamp) do
    now = NaiveDateTime.utc_now()
    diff_seconds = NaiveDateTime.diff(now, timestamp, :second)

    cond do
      diff_seconds < 60 -> "just now"
      diff_seconds < 60 * 60 -> "#{div(diff_seconds, 60)} minutes ago"
      diff_seconds < 60 * 60 * 24 -> "#{div(diff_seconds, 60 * 60)} hours ago"
      diff_seconds < 60 * 60 * 24 * 7 -> "#{div(diff_seconds, 60 * 60 * 24)} days ago"
      diff_seconds < 60 * 60 * 24 * 30 -> "#{div(diff_seconds, 60 * 60 * 24 * 7)} weeks ago"
      true -> Calendar.strftime(timestamp, "%b %d, %Y at %H:%M")
    end
  end

  defp format_relative_time(%DateTime{} = timestamp) do
    timestamp
    |> DateTime.to_naive()
    |> format_relative_time()
  end

  defp format_relative_time(_), do: "recently"

  # Generate a consistent ID for activities that don't have one
  defp generate_activity_id(activity) do
    type = activity[:type] || "activity"
    timestamp = activity[:timestamp] || DateTime.utc_now()
    type_str = if is_atom(type), do: Atom.to_string(type), else: type

    "activity-#{type_str}-#{:erlang.phash2(timestamp)}"
  end
end
