defmodule CodeHorizonWeb.LMSComponents.AssessmentComponents do
  @moduledoc """
  Specialized components for assessment-related features.
  Renders assessment cards, lists, and other assessment-specific UI elements.
  """
  use Phoenix.Component
  use PetalComponents

  import CodeHorizonWeb.FeatureCards

  @doc """
  Renders an assessment item with consistent styling.

  ## Attributes

  * `assessment` - Required map containing assessment data
  * `phx_click` - Phoenix event to trigger when clicking the action button
  * `class` - Additional CSS classes to apply
  * `rest` - Additional HTML attributes

  ## Assessment Types

  - `:quiz` - Multiple choice or short answer quiz
  - `:exam` - Comprehensive assessment with time limit
  - `:assignment` - Project or homework assignment
  - `:practical` - Hands-on assessment with coding or other practical elements

  ## Examples

      <.assessment_item
        assessment={assessment}
        phx_click="start_assessment"
      />
  """
  attr :assessment, :map, required: true, doc: "Assessment data"
  attr :phx_click, :string, default: "view_assessment_details", doc: "Phoenix click event"
  attr :class, :string, default: "", doc: "Additional CSS classes"
  attr :rest, :global, doc: "Additional HTML attributes"

  def assessment_item(assigns) do
    # Use the generic content_item with assessment-specific data
    ~H"""
    <.content_item
      title={@assessment.title}
      image={@assessment[:cover_image] || @assessment[:image]}
      badge_text={get_assessment_type_text(@assessment.assessment_type)}
      badge_icon={get_assessment_type_icon(@assessment.assessment_type)}
      metadata={build_assessment_metadata(@assessment)}
      tags={build_assessment_tags(@assessment)}
      action_text={get_assessment_action_text(@assessment)}
      phx_click={@phx_click}
      item_id={@assessment.id}
      class={@class}
      {@rest}
    />
    """
  end

  @doc """
  Renders a list of assessments.

  ## Attributes

  * `assessments` - List of assessment maps to display
  * `phx_click` - Phoenix event to trigger when clicking an assessment
  * `empty_state` - Map with title, message, and action for empty state
  * `class` - Additional CSS classes to apply

  ## Examples

      <.assessment_list
        assessments={@assessments}
        phx_click="view_assessment_details"
        empty_state={%{
          title: "No assessments",
          message: "You don't have any assessments to complete.",
          button_text: "Back to courses",
          button_path: ~p"/app/courses"
        }}
      />
  """
  attr :assessments, :list, required: true, doc: "List of assessments to display"
  attr :phx_click, :string, default: "view_assessment_details", doc: "Phoenix click event"
  attr :empty_state, :map, default: %{}, doc: "Empty state configuration"
  attr :class, :string, default: "", doc: "Additional CSS classes"
  attr :grid, :boolean, default: false, doc: "Use grid layout instead of vertical list"

  def assessment_list(assigns) do
    assigns =
      assign_new(assigns, :empty_state, fn ->
        %{
          title: "No assessments",
          message: "You don't have any pending assessments. Great job!",
          icon: "hero-clipboard-document-check"
        }
      end)

    ~H"""
    <div class={
      if @grid,
        do: "grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 #{@class}",
        else: "space-y-4 #{@class}"
    }>
      <%= if Enum.empty?(@assessments) do %>
        <div class="text-center py-12 px-6 col-span-full">
          <div class="bg-[color:var(--color-primary-50)] dark:bg-[color:var(--color-primary-900/20)] rounded-full h-20 w-20 flex items-center justify-center mx-auto mb-4 shadow-inner">
            <.icon
              name={@empty_state[:icon] || "hero-clipboard-document-check"}
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
        <%= for assessment <- @assessments do %>
          <.assessment_item
            assessment={assessment}
            phx_click={@phx_click}
            id={assessment[:id] || generate_assessment_id(assessment)}
          />
        <% end %>
      <% end %>
    </div>
    """
  end

  @doc """
  Filters assessments by type or status.

  ## Attributes

  * `assessments` - List of assessment maps to filter
  * `types` - Optional list of assessment types to include
  * `status` - Optional status to filter by (upcoming, completed, in_progress)
  * `limit` - Maximum number of assessments to return

  ## Examples

      <.assessment_list
        assessments={filter_assessments(@all_assessments, [:quiz, :exam], "upcoming", 5)}
      />
  """
  def filter_assessments(assessments, types \\ nil, status \\ nil, limit \\ nil) do
    assessments
    |> then(fn list ->
      if types do
        Enum.filter(list, fn assessment ->
          assessment_type = assessment[:assessment_type]
          assessment_type_atom = if is_atom(assessment_type), do: assessment_type, else: String.to_atom(assessment_type)
          Enum.member?(types, assessment_type_atom)
        end)
      else
        list
      end
    end)
    |> then(fn list ->
      if status do
        case status do
          "upcoming" ->
            Enum.filter(list, fn assessment ->
              due_date = assessment[:due_date]
              due_date && Date.compare(due_date, Date.utc_today()) in [:gt, :eq]
            end)

          "completed" ->
            Enum.filter(list, fn assessment -> assessment[:is_completed] || assessment[:status] == "completed" end)

          "in_progress" ->
            Enum.filter(list, fn assessment -> assessment[:status] == "in_progress" end)

          _ ->
            list
        end
      else
        list
      end
    end)
    |> then(fn filtered ->
      if limit, do: Enum.take(filtered, limit), else: filtered
    end)
  end

  # Helper Functions

  @doc """
  Gets the descriptive text for an assessment type.

  ## Examples

      iex> get_assessment_type_text(:quiz)
      "Quiz"

      iex> get_assessment_type_text(:exam)
      "Exam"
  """
  def get_assessment_type_text(type) when is_binary(type), do: get_assessment_type_text(String.to_atom(type))
  def get_assessment_type_text(:quiz), do: "Quiz"
  def get_assessment_type_text(:exam), do: "Exam"
  def get_assessment_type_text(:assignment), do: "Assignment"
  def get_assessment_type_text(:practical), do: "Practical"
  def get_assessment_type_text(type) when is_atom(type), do: String.capitalize(to_string(type))
  def get_assessment_type_text(type) when is_binary(type), do: String.capitalize(type)
  def get_assessment_type_text(_), do: "Assessment"

  @doc """
  Gets the icon for an assessment type.

  ## Examples

      iex> get_assessment_type_icon(:quiz)
      "hero-clipboard-document-list"

      iex> get_assessment_type_icon(:exam)
      "hero-document-check"
  """
  def get_assessment_type_icon(type) when is_binary(type), do: get_assessment_type_icon(String.to_atom(type))
  def get_assessment_type_icon(:quiz), do: "hero-clipboard-document-list"
  def get_assessment_type_icon(:exam), do: "hero-document-check"
  def get_assessment_type_icon(:assignment), do: "hero-document-text"
  def get_assessment_type_icon(:practical), do: "hero-code-bracket-square"
  def get_assessment_type_icon(_), do: "hero-clipboard"

  @doc """
  Gets the badge color for an assessment type.

  ## Examples

      iex> get_assessment_badge_color(:quiz)
      "info"

      iex> get_assessment_badge_color(:exam)
      "warning"
  """
  def get_assessment_badge_color(type) when is_binary(type), do: get_assessment_badge_color(String.to_atom(type))
  def get_assessment_badge_color(:quiz), do: "info"
  def get_assessment_badge_color(:exam), do: "warning"
  def get_assessment_badge_color(:assignment), do: "success"
  def get_assessment_badge_color(:practical), do: "primary"
  def get_assessment_badge_color(_), do: "secondary"

  @doc """
  Gets the appropriate action text based on assessment status.

  ## Examples

      iex> get_assessment_action_text(%{is_completed: true})
      "View Results"

      iex> get_assessment_action_text(%{status: "in_progress"})
      "Continue"

      iex> get_assessment_action_text(%{})
      "Start Assessment"
  """
  def get_assessment_action_text(assessment) do
    cond do
      assessment[:is_completed] || assessment[:status] == "completed" -> "View Results"
      assessment[:status] == "in_progress" -> "Continue"
      true -> "Start Assessment"
    end
  end

  @doc """
  Formats a due date with appropriate styling class based on urgency.

  ## Examples

      iex> format_due_date(~D[2023-12-31])
      %{text: "Dec 31, 2023", class: "text-gray-500", dark_class: "dark:text-gray-400"}

      iex> format_due_date(Date.utc_today())
      %{text: "Today", class: "text-amber-500", dark_class: "dark:text-amber-400"}
  """
  def format_due_date(due_date) do
    days_until = Date.diff(due_date, Date.utc_today())

    text =
      cond do
        days_until < 0 -> "Overdue: #{Calendar.strftime(due_date, "%b %d, %Y")}"
        days_until == 0 -> "Today"
        days_until == 1 -> "Tomorrow"
        days_until < 7 -> "In #{days_until} days"
        true -> Calendar.strftime(due_date, "%b %d, %Y")
      end

    # Classes visuais mais elaboradas para diferentes estados
    class =
      cond do
        days_until < 0 -> "text-red-500 font-medium"
        days_until == 0 -> "text-amber-500 font-medium"
        days_until <= 3 -> "text-amber-500"
        true -> "text-gray-500"
      end

    dark_class =
      cond do
        days_until < 0 -> "dark:text-red-400 font-medium"
        days_until == 0 -> "dark:text-amber-400 font-medium"
        days_until <= 3 -> "dark:text-amber-400"
        true -> "dark:text-gray-400"
      end

    bg_class =
      cond do
        days_until < 0 -> "bg-red-50 dark:bg-red-900/10"
        days_until <= 3 -> "bg-amber-50 dark:bg-amber-900/10"
        true -> ""
      end

    icon =
      cond do
        days_until < 0 -> "hero-exclamation-circle"
        days_until <= 3 -> "hero-clock"
        true -> "hero-calendar"
      end

    %{
      text: text,
      class: class,
      dark_class: dark_class,
      bg_class: bg_class,
      icon: icon
    }
  end

  @doc """
  Builds metadata array for an assessment.

  Creates a list of metadata items with icons, text, and optional highlighting.

  ## Examples

      iex> build_assessment_metadata(%{course_title: "Programming 101", due_date: ~D[2023-12-31]})
      [
        %{icon: "hero-book-open", text: "Programming 101"},
        %{icon: "hero-calendar", text: "Due: Dec 31, 2023", highlight: false, class: "text-gray-500", dark_class: "dark:text-gray-400"}
      ]
  """
  def build_assessment_metadata(assessment) do
    metadata = []

    # Add course title if available
    metadata =
      if assessment[:course_title] do
        metadata ++
          [
            %{
              icon: "hero-book-open",
              text: assessment.course_title
            }
          ]
      else
        metadata
      end

    # Add due date if available
    metadata =
      if assessment[:due_date] do
        due_date_info = format_due_date(assessment.due_date)

        metadata ++
          [
            %{
              icon: due_date_info.icon,
              text: "Due: #{due_date_info.text}",
              highlight: Date.diff(assessment.due_date, Date.utc_today()) <= 3,
              class: "#{due_date_info.class} #{due_date_info.bg_class} px-2 py-0.5 rounded-md",
              dark_class: due_date_info.dark_class
            }
          ]
      else
        metadata
      end

    # Add time limit if available
    metadata =
      if assessment[:time_limit_minutes] do
        time_text =
          if assessment.time_limit_minutes >= 60 do
            hours = div(assessment.time_limit_minutes, 60)
            minutes = rem(assessment.time_limit_minutes, 60)
            if minutes == 0, do: "#{hours} hours", else: "#{hours} hours #{minutes} minutes"
          else
            "#{assessment.time_limit_minutes} minutes"
          end

        metadata ++
          [
            %{
              icon: "hero-clock",
              text: "Time limit: #{time_text}"
            }
          ]
      else
        metadata
      end

    # Add points if available
    metadata =
      if assessment[:total_points] do
        metadata ++
          [
            %{
              icon: "hero-star",
              text: "Points: #{assessment.total_points}"
            }
          ]
      else
        metadata
      end

    # Add attempts if available
    metadata =
      if assessment[:attempts] && assessment[:max_attempts] do
        metadata ++
          [
            %{
              icon: "hero-arrow-path",
              text: "Attempts: #{assessment.attempts}/#{assessment.max_attempts}"
            }
          ]
      else
        metadata
      end

    metadata
  end

  @doc """
  Builds tags array for an assessment.

  Creates a list of tag items with icons and text for display in the UI.

  ## Examples

      iex> build_assessment_tags(%{question_count: 10, status: "published", difficulty: "Intermediate"})
      [
        %{icon: "hero-question-mark-circle", text: "10 questions"},
        %{icon: "hero-signal", text: "Intermediate"}
      ]
  """
  def build_assessment_tags(assessment) do
    tags = []

    # Add question count if available
    tags =
      if assessment[:question_count] do
        question_text =
          "#{assessment.question_count} #{if assessment.question_count == 1, do: "question", else: "questions"}"

        tags ++ [%{icon: "hero-question-mark-circle", text: question_text}]
      else
        tags
      end

    # Add difficulty if available
    tags =
      if assessment[:difficulty] do
        tags ++ [%{icon: "hero-signal", text: assessment.difficulty}]
      else
        tags
      end

    # Add status if available (and not completed, which would be a badge)
    tags =
      if assessment[:status] && assessment[:status] != "completed" do
        tags ++ [%{icon: "hero-document-text", text: String.capitalize(assessment.status)}]
      else
        tags
      end

    tags
  end

  # Generate a consistent ID for assessments that don't have one
  defp generate_assessment_id(assessment) do
    title = assessment[:title] || "assessment"
    type = assessment[:assessment_type] || "unknown"
    type_str = if is_atom(type), do: Atom.to_string(type), else: type

    "assessment-#{type_str}-#{:erlang.phash2(title)}"
  end
end
