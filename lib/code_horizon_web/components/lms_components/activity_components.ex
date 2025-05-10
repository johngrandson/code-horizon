defmodule CodeHorizonWeb.LMSComponents.ActivityComponents do
  @moduledoc """
  Specialized components for activity-related features.
  Renders activity cards, lists, and other activity-specific UI elements.
  """
  use Phoenix.Component
  use PetalComponents

  @doc """
  Renders an activity item with enhanced styling and consistent visual hierarchy.

  ## Attributes

  * `activity` - Required map containing activity data
  * `class` - Additional CSS classes to apply
  * `rest` - Additional HTML attributes
  * `compact` - Whether to display in compact mode
  * `width_class` - Width class for the container
  * `height_class` - Height class for the container

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
        compact={false}
      />
  """
  attr :activity, :map, required: true, doc: "Activity data"
  attr :class, :string, default: "", doc: "Additional CSS classes"
  attr :rest, :global, doc: "Additional HTML attributes"
  attr :compact, :boolean, default: false, doc: "Whether to display in compact mode"
  attr :width_class, :string, default: "w-full", doc: "Width class for the container"
  attr :height_class, :string, default: "h-full", doc: "Height class for the container"

  def activity_item(assigns) do
    assigns = assign_new(assigns, :compact, fn -> false end)
    assigns = assign_new(assigns, :width_class, fn -> "w-full" end)
    assigns = assign_new(assigns, :height_class, fn -> "h-full" end)

    ~H"""
    <div
      class={"group overflow-hidden rounded-xl transition-all duration-300 hover:shadow-lg border border-[color:var(--color-primary-200)] dark:border-[color:var(--color-primary-800)]/50 bg-white dark:bg-gray-800 relative flex flex-col #{@width_class} #{@height_class} #{@class}"}
      {@rest}
    >
      <div class="flex flex-col h-full">
        <!-- Decorative activity type indicator -->
        <div class="h-1.5 w-full bg-gradient-to-r from-[color:var(--color-primary-400)] via-[color:var(--color-primary-500)] to-[color:var(--color-primary-600)] shadow-sm">
        </div>

        <div class="relative w-full flex-shrink-0 overflow-hidden">
          <!-- Activity thumbnail with overlay -->
          <div class={"#{if @compact, do: "aspect-[45/9]", else: "aspect-[16/9]"} w-full overflow-hidden"}>
            <img
              src={@activity[:cover_image] || activity_default_image(@activity.type)}
              alt={get_activity_title(@activity)}
              class="w-full h-full object-cover transform transition-transform duration-700 group-hover:scale-105"
              loading="lazy"
            />
            <div class="absolute inset-0 bg-gradient-to-t from-black/80 via-black/40 to-transparent">
            </div>
          </div>

          <div class={"absolute #{if @compact, do: "top-2 left-2", else: "top-3 left-3"} flex items-center space-x-1 bg-black/40 backdrop-blur-sm rounded-full px-2 py-0.5 border border-[color:var(--color-primary-500)]/30"}>
            <!-- Activity badge -->
            <.icon
              name={get_activity_badge_icon(@activity)}
              class="w-3.5 h-3.5 text-[color:var(--color-primary-400)]"
            />
            <span class="text-xs font-medium text-white">{get_activity_badge(@activity)}</span>
          </div>

          <%= if @activity[:score] || @activity[:completion_status] do %>
            <!-- Score or completion status if available -->
            <div class={"absolute bottom-0 left-0 right-0 #{if @compact, do: "p-2", else: "p-3"} flex flex-col gap-1.5"}>
              <%= if @activity[:score] do %>
                <div class="flex items-center">
                  <div class="px-1.5 py-0.5 bg-gradient-to-r from-[color:var(--color-primary-500)] to-[color:var(--color-primary-600)] text-white text-xs font-bold rounded-md flex items-center shadow-sm">
                    {@activity.score}% <.icon name="hero-academic-cap" class="w-3 h-3 ml-0.5" />
                  </div>
                </div>
              <% end %>

              <%= unless @compact do %>
                <div class="flex items-center gap-1.5 flex-wrap">
                  <div class="bg-white/20 backdrop-blur-sm text-white text-xs py-0.5 px-2 rounded-full border border-white/10">
                    {activity_category(@activity)}
                  </div>

                  <%= if @activity[:completion_status] do %>
                    <div class="bg-white/20 backdrop-blur-sm text-white text-xs py-0.5 px-2 rounded-full border border-white/10 flex items-center">
                      <.icon name={activity_status_icon(@activity)} class="w-3 h-3 mr-1" />
                      {@activity.completion_status}
                    </div>
                  <% end %>
                </div>
              <% end %>
            </div>
          <% end %>
        </div>

        <div class={"#{if @compact, do: "p-3", else: "p-4 lg:p-5"} flex-grow flex flex-col"}>
          <!-- Activity information -->
          <div>
            <!-- Activity title - smaller in compact mode -->
            <h3 class={"#{if @compact, do: "text-base", else: "text-lg"} font-bold mb-1 line-clamp-2 tracking-tight text-gray-900 dark:text-white group-hover:text-[color:var(--color-primary-600)] dark:group-hover:text-[color:var(--color-primary-400)] transition-colors duration-300"}>
              {get_activity_title(@activity)}
            </h3>

            <%= unless @compact do %>
              <p class="text-xs text-gray-500 dark:text-gray-400 mb-2 flex items-center">
                <.icon
                  name="hero-clock"
                  class="w-3 h-3 mr-1 text-[color:var(--color-primary-500)]/70 dark:text-[color:var(--color-primary-400)]/70"
                /> {format_datetime(@activity.timestamp)}
              </p>

              <%= if @activity[:description] do %>
                <p class="text-sm text-gray-600 dark:text-gray-400 mb-4 line-clamp-2">
                  {@activity.description}
                </p>
              <% end %>
            <% end %>
          </div>

          <%= if @activity[:progress] do %>
            <!-- Progress bar if applicable -->
            <div class="mb-1 flex items-center justify-between">
              <span class="text-xs font-medium text-gray-700 dark:text-gray-300">
                <%= if @compact do %>
                  Progress
                <% else %>
                  Activity Progress
                <% end %>
              </span>
              <span class="text-xs font-medium text-gray-700 dark:text-gray-300">
                {@activity.progress}%
              </span>
            </div>
            <.progress
              value={@activity.progress}
              class="h-2 rounded-full bg-gray-100 dark:bg-gray-700"
              color="primary"
            />

            <%= unless @compact do %>
              <%= if @activity.progress == 100 do %>
                <div class="mt-2 px-2 py-1 bg-gradient-to-r from-green-500 to-green-600 text-white text-xs font-bold rounded-md inline-flex items-center shadow-sm">
                  <.icon name="hero-check-circle" class="w-3.5 h-3.5 mr-1" /> Completed!
                </div>
              <% end %>
            <% end %>
          <% end %>

          <%= unless @compact do %>
            <!-- Activity details - only if not compact -->
            <div class="flex flex-wrap gap-3 mb-4 mt-auto">
              <%= if @activity[:duration] do %>
                <div
                  class="flex items-center bg-[color:var(--color-primary-50)] dark:bg-[color:var(--color-primary-900)]/20 px-2 py-1 rounded-md shadow-sm border border-[color:var(--color-primary-100)] dark:border-[color:var(--color-primary-800)]/30"
                  title="Activity duration"
                >
                  <.icon
                    name="hero-clock"
                    class="w-3.5 h-3.5 mr-1.5 text-[color:var(--color-primary-600)] dark:text-[color:var(--color-primary-400)]"
                  />
                  <span class="text-xs font-medium text-gray-700 dark:text-gray-300">
                    {@activity.duration}
                  </span>
                </div>
              <% end %>

              <%= if @activity[:attempts] do %>
                <div
                  class="flex items-center bg-[color:var(--color-primary-50)] dark:bg-[color:var(--color-primary-900)]/20 px-2 py-1 rounded-md shadow-sm border border-[color:var(--color-primary-100)] dark:border-[color:var(--color-primary-800)]/30"
                  title="Attempts made"
                >
                  <.icon
                    name="hero-arrow-path"
                    class="w-3.5 h-3.5 mr-1.5 text-[color:var(--color-primary-600)] dark:text-[color:var(--color-primary-400)]"
                  />
                  <span class="text-xs font-medium text-gray-700 dark:text-gray-300">
                    {pluralize(@activity.attempts, "attempt", "attempts")}
                  </span>
                </div>
              <% end %>

              <%= for {key, value} <- build_activity_metadata(@activity) do %>
                <div
                  class="flex items-center bg-[color:var(--color-primary-50)] dark:bg-[color:var(--color-primary-900)]/20 px-2 py-1 rounded-md shadow-sm border border-[color:var(--color-primary-100)] dark:border-[color:var(--color-primary-800)]/30"
                  title={key}
                >
                  <.icon
                    name={metadata_icon(key)}
                    class="w-3.5 h-3.5 mr-1.5 text-[color:var(--color-primary-600)] dark:text-[color:var(--color-primary-400)]"
                  />
                  <span class="text-xs font-medium text-gray-700 dark:text-gray-300">
                    {value}
                  </span>
                </div>
              <% end %>
            </div>

            <%= if @activity[:related_item] do %>
              <!-- Related item info -->
              <div class="flex items-center p-3 mb-4 rounded-lg bg-gray-50 dark:bg-gray-700/30 border border-gray-100 dark:border-gray-700">
                <div class="w-9 h-9 rounded-full overflow-hidden mr-3 ring-2 ring-[color:var(--color-primary-200)] dark:ring-[color:var(--color-primary-800)]/50">
                  <img
                    src={@activity.related_item[:cover_image] || "/images/default-course.jpg"}
                    alt={@activity.related_item[:title]}
                    class="w-full h-full object-cover"
                  />
                </div>
                <div>
                  <p class="text-sm font-medium text-gray-900 dark:text-white flex items-center">
                    {@activity.related_item.title}
                  </p>
                  <p class="text-xs text-gray-500 dark:text-gray-400">
                    {related_item_type(@activity.related_item)}
                  </p>
                </div>
              </div>
            <% end %>
          <% else %>
            <!-- Compact version: show minimal related info -->
            <%= if @activity[:related_item] do %>
              <div class="flex items-center mt-1 mb-1">
                <div class="w-5 h-5 rounded-full overflow-hidden mr-1.5">
                  <img
                    src={@activity.related_item[:cover_image] || "/images/default-course.jpg"}
                    alt={@activity.related_item[:title]}
                    class="w-full h-full object-cover"
                  />
                </div>
                <p class="text-xs text-gray-700 dark:text-gray-300 truncate">
                  {@activity.related_item.title}
                </p>
              </div>
            <% end %>
          <% end %>

          <div class={"flex items-center justify-between mt-auto #{if @compact, do: "pt-2", else: "pt-3"} border-t border-gray-100 dark:border-gray-700"}>
            <!-- Activity timestamp and action button -->
            <div class="flex flex-col">
              <span class={"#{if @compact, do: "text-xs", else: "text-sm"} text-gray-500 dark:text-gray-400"}>
                {format_relative_time(@activity.timestamp)}
              </span>
            </div>

            <.button
              color="primary"
              phx-click={get_activity_action(@activity.type)}
              phx-value-id={@activity.id}
              size={if @compact, do: "xs", else: "sm"}
              class="font-medium shadow transition-all duration-300 transform group-hover:scale-105"
            >
              {get_activity_action_text(@activity.type)}
              <.icon
                name="hero-arrow-right"
                class={"#{if @compact, do: "w-3.5 h-3.5", else: "w-4 h-4"} ml-1 group-hover:translate-x-0.5 transition-transform"}
              />
            </.button>
          </div>
        </div>
      </div>
    </div>
    """
  end

  # Helper functions for the activity item
  defp activity_default_image(type) do
    case type do
      :course_enrolled -> "/images/activities/course-enrolled.jpg"
      :course_completed -> "/images/activities/course-completed.jpg"
      :lesson_completed -> "/images/activities/lesson-completed.jpg"
      :assessment_completed -> "/images/activities/assessment-completed.jpg"
      :assessment_submitted -> "/images/activities/assessment-submitted.jpg"
      :quiz_attempt -> "/images/activities/quiz-attempt.jpg"
      _ -> "/images/activities/default.jpg"
    end
  end

  defp activity_category(activity) do
    case activity.type do
      :lesson_completed -> "Lesson"
      :course_enrolled -> "Course"
      :course_completed -> "Course"
      :assessment_completed -> "Assessment"
      :assessment_submitted -> "Assessment"
      :quiz_attempt -> "Quiz"
      _ -> "Activity"
    end
  end

  defp activity_status_icon(activity) do
    case activity.completion_status do
      "Completed" -> "hero-check-circle"
      "In Progress" -> "hero-arrow-path"
      "Not Started" -> "hero-clock"
      _ -> "hero-information-circle"
    end
  end

  defp get_activity_badge_icon(activity) do
    case activity.type do
      :course_enrolled -> "hero-academic-cap"
      :course_completed -> "hero-trophy"
      :lesson_completed -> "hero-book-open"
      :assessment_completed -> "hero-clipboard-document-check"
      :assessment_submitted -> "hero-clipboard-document"
      :quiz_attempt -> "hero-puzzle-piece"
      _ -> "hero-star"
    end
  end

  defp metadata_icon(key) do
    case key do
      "Questions" -> "hero-question-mark-circle"
      "Score" -> "hero-star"
      "Time Spent" -> "hero-clock"
      "Points" -> "hero-bolt"
      "XP" -> "hero-sparkles"
      _ -> "hero-information-circle"
    end
  end

  defp related_item_type(related_item) do
    case related_item[:type] do
      "course" -> "Course"
      "lesson" -> "Lesson"
      "assessment" -> "Assessment"
      "quiz" -> "Quiz"
      _ -> "Item"
    end
  end

  defp pluralize(count, singular, plural) do
    if count == 1 do
      "#{count} #{singular}"
    else
      "#{count} #{plural}"
    end
  end

  defp format_datetime(timestamp) do
    # Format the timestamp as needed
    Calendar.strftime(timestamp, "%b %d, %Y at %H:%M")
  end

  defp format_relative_time(timestamp) do
    now = DateTime.utc_now()

    # Converter timestamp para UTC DateTime se necessário
    timestamp_dt =
      cond do
        # Se já for DateTime, use-o diretamente
        match?(%DateTime{}, timestamp) ->
          timestamp

        # Se for NaiveDateTime, converta para DateTime
        match?(%NaiveDateTime{}, timestamp) ->
          {:ok, dt} = DateTime.from_naive(timestamp, "Etc/UTC")
          dt

        # Para outros casos, retorne o "agora" para evitar erros
        true ->
          now
      end

    diff = DateTime.diff(now, timestamp_dt, :second)

    cond do
      diff < 60 -> "Just now"
      diff < 3600 -> "#{div(diff, 60)} minutes ago"
      diff < 86_400 -> "#{div(diff, 3600)} hours ago"
      diff < 604_800 -> "#{div(diff, 86_400)} days ago"
      diff < 2_592_000 -> "#{div(diff, 604_800)} weeks ago"
      true -> "#{div(diff, 2_592_000)} months ago"
    end
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
      activity[:lesson_title] -> activity.lesson_title
      activity[:course_title] -> activity.course_title
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
      activity[:type] == :course_enrolled || activity[:type] == "course_enrolled" -> "Enrolled"
      activity[:type] == :course_completed || activity[:type] == "course_completed" -> "Completed"
      activity[:type] == :assessment_completed || activity[:type] == "assessment_completed" -> "Assessment"
      activity[:type] == :lesson_completed || activity[:type] == "lesson_completed" -> "Lesson"
      true -> nil
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

  # Generate a consistent ID for activities that don't have one
  defp generate_activity_id(activity) do
    type = activity[:type] || "activity"
    timestamp = activity[:timestamp] || DateTime.utc_now()
    type_str = if is_atom(type), do: Atom.to_string(type), else: type

    "activity-#{type_str}-#{:erlang.phash2(timestamp)}"
  end
end
