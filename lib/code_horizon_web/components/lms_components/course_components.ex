defmodule CodeHorizonWeb.LMSComponents.CourseComponents do
  @moduledoc """
  Specialized components for course-related features.
  Renders course cards, lists, and other course-specific UI elements.
  """
  use Phoenix.Component
  use PetalComponents

  import CodeHorizonWeb.FeatureCards

  @doc """
  Renders a course item with consistent styling.

  ## Attributes

  * `course` - Required map containing course data
  * `phx_click` - Phoenix event to trigger when clicking the action button
  * `class` - Additional CSS classes to apply
  * `rest` - Additional HTML attributes

  ## Examples

      <.course_item
        course={course}
        phx_click="explore_course"
      />
  """
  attr :course, :map, required: true, doc: "Course data"
  attr :phx_click, :string, default: "explore_course", doc: "Phoenix click event"
  attr :class, :string, default: "", doc: "Additional CSS classes"
  attr :rest, :global, doc: "Additional HTML attributes"

  def course_item(assigns) do
    # Use the generic content_item with course-specific data
    ~H"""
    <.content_item
      title={@course.title}
      image={@course[:cover_image] || @course[:image] || "/images/default-course.jpg"}
      progress={@course[:progress]}
      badge_text={get_progress_badge(@course[:progress])}
      badge_icon={get_progress_icon(@course[:progress])}
      metadata={build_course_metadata(@course)}
      tags={build_course_tags(@course)}
      action_text="Continue"
      phx_click={@phx_click}
      item_id={@course.id}
      class={"bg-gradient-to-br from-white to-[color:var(--color-primary-50)]/10 dark:from-gray-800 dark:to-gray-800/95 #{@class}"}
      {@rest}
    />
    """
  end

  @doc """
  Renders a featured course item with enhanced styling.

  ## Attributes

  * `course` - Required map containing course data
  * `phx_click` - Phoenix event to trigger when clicking the action button
  * `class` - Additional CSS classes to apply
  * `rest` - Additional HTML attributes

  ## Examples

      <.featured_course_item
        course={course}
        phx_click="explore_course"
      />
  """
  attr :course, :map, required: true, doc: "Course data"
  attr :phx_click, :string, default: "explore_course", doc: "Phoenix click event"
  attr :class, :string, default: "", doc: "Additional CSS classes"
  attr :rest, :global, doc: "Additional HTML attributes"

  def featured_course_item(assigns) do
    ~H"""
    <div
      class={"group overflow-hidden rounded-xl transition-all duration-300 hover:shadow-lg border border-[color:var(--color-primary-200)] dark:border-[color:var(--color-primary-800)]/50 bg-white dark:bg-gray-800 relative #{@class}"}
      {@rest}
    >
      <!-- Decorative top bar -->
      <div class="h-1.5 w-full bg-gradient-to-r from-[color:var(--color-primary-400)] via-[color:var(--color-primary-500)] to-[color:var(--color-primary-600)] shadow-sm">
      </div>

      <div class="relative">
        <!-- Course image with overlay -->
        <div class="aspect-video w-full overflow-hidden">
          <img
            src={@course[:cover_image] || @course[:image] || "/images/default-course.jpg"}
            alt={@course.title}
            class="w-full h-full object-cover transform transition-transform duration-700 group-hover:scale-105"
            loading="lazy"
          />
          <div class="absolute inset-0"></div>
        </div>

        <%= if @course[:is_premium] do %>
          <div class="absolute top-3 left-3 flex items-center space-x-1 bg-black/40 backdrop-blur-sm rounded-full px-2 py-0.5 border border-[color:var(--color-primary-500)]/30">
            <.icon name="hero-sparkles" class="w-3.5 h-3.5 text-[color:var(--color-primary-400)]" />
            <span class="text-xs font-medium text-white">Premium</span>
          </div>
        <% end %>

        <%= if @course[:discount_percentage] do %>
          <div class="absolute -right-9 top-6 bg-gradient-to-r from-[color:var(--color-primary-600)] to-red-600 text-white px-10 py-1 transform rotate-45 shadow-lg text-xs font-bold">
            {@course.discount_percentage}% OFF
          </div>
        <% end %>
        
    <!-- Course details -->
        <div class="p-5">
          <h3 class="text-lg font-bold tracking-tight text-gray-900 dark:text-white group-hover:text-[color:var(--color-primary-600)] dark:group-hover:text-[color:var(--color-primary-400)] transition-colors duration-300 line-clamp-2 mb-2">
            {@course.title}
          </h3>

          <%= if @course[:progress] do %>
            <div class="mb-1 flex items-center justify-between">
              <span class="text-xs font-medium text-gray-700 dark:text-gray-300">
                Progress
              </span>
              <span class="text-xs font-medium text-gray-700 dark:text-gray-300">
                {@course.progress}%
              </span>
            </div>
            <.progress
              value={@course.progress}
              class="h-2 rounded-full bg-gray-100 dark:bg-gray-700"
              color="primary"
            />

            <%= if @course.progress > 75 && @course.progress < 100 do %>
              <div class="mt-2 px-2 py-1 bg-gradient-to-r from-[color:var(--color-primary-500)] to-[color:var(--color-primary-600)] text-white text-xs font-bold rounded-md inline-flex items-center shadow-sm">
                <.icon name="hero-fire" class="w-3.5 h-3.5 mr-1" /> Almost done!
              </div>
            <% end %>
            <%= if @course.progress == 100 do %>
              <div class="mt-2 px-2 py-1 bg-gradient-to-r from-green-500 to-green-600 text-white text-xs font-bold rounded-md inline-flex items-center shadow-sm">
                <.icon name="hero-check-circle" class="w-3.5 h-3.5 mr-1" /> Completed!
              </div>
            <% end %>
          <% end %>
          
    <!-- Course metadata -->
          <div class="mt-3">
            <%= for item <- build_course_metadata(@course) do %>
              <div class={[
                "text-sm flex items-center mb-1",
                Map.get(item, :class, "text-gray-500 dark:text-gray-400"),
                Map.get(item, :dark_class, "")
              ]}>
                <%= if Map.get(item, :icon) do %>
                  <div class={"w-5 h-5 mr-1.5 flex items-center justify-center #{if Map.get(item, :highlight), do: "text-[color:var(--color-primary-600)] dark:text-[color:var(--color-primary-400)]", else: "text-gray-400 dark:text-gray-500"}"}>
                    <.icon name={item.icon} class="w-4 h-4" />
                  </div>
                <% end %>
                <span>
                  {item.text}
                  <%= if Map.get(item, :additional) do %>
                    <span class={"#{if Map.get(item, :highlight_additional), do: "font-medium text-gray-700 dark:text-gray-300", else: ""}"}>
                      {item.additional}
                    </span>
                  <% end %>
                </span>
              </div>
            <% end %>
          </div>
          
    <!-- Tags -->
          <div class="flex flex-wrap gap-3 my-3">
            <%= for tag <- build_course_tags(@course) do %>
              <div class="flex items-center bg-[color:var(--color-primary-50)] dark:bg-[color:var(--color-primary-900/20)] px-2 py-1 rounded-md shadow-sm border border-[color:var(--color-primary-100)] dark:border-[color:var(--color-primary-800/30)]">
                <%= if Map.get(tag, :icon) do %>
                  <.icon
                    name={tag.icon}
                    class="w-3.5 h-3.5 mr-1.5 text-[color:var(--color-primary-600)] dark:text-[color:var(--color-primary-400)]"
                  />
                <% end %>
                <span class="text-xs font-medium text-gray-700 dark:text-gray-300">
                  {tag.text}
                </span>
              </div>
            <% end %>
          </div>
          
    <!-- Action button -->
          <div class="mt-3 flex justify-end">
            <.button
              color="primary"
              phx-click={@phx_click}
              phx-value-id={@course.id}
              class="font-medium shadow transition-all duration-300 transform group-hover:scale-105"
            >
              Continue
              <.icon
                name="hero-arrow-right"
                class="w-4 h-4 ml-1 group-hover:translate-x-0.5 transition-transform"
              />
            </.button>
          </div>
        </div>
      </div>
    </div>
    """
  end

  # Helper Functions

  @doc """
  Determines badge text based on course progress.

  ## Examples

      iex> get_progress_badge(100)
      "Completed!"

      iex> get_progress_badge(80)
      "Almost done!"

      iex> get_progress_badge(50)
      nil
  """
  def get_progress_badge(progress) when is_integer(progress) and progress == 100, do: "Completed!"
  def get_progress_badge(progress) when is_integer(progress) and progress >= 75, do: "Almost done!"
  def get_progress_badge(_), do: nil

  @doc """
  Determines badge icon based on course progress.

  ## Examples

      iex> get_progress_icon(100)
      "hero-check-circle"

      iex> get_progress_icon(80)
      "hero-fire"

      iex> get_progress_icon(50)
      nil
  """
  def get_progress_icon(progress) when is_integer(progress) and progress == 100, do: "hero-check-circle"
  def get_progress_icon(progress) when is_integer(progress) and progress >= 75, do: "hero-fire"
  def get_progress_icon(_), do: nil

  @doc """
  Builds metadata array for a course.

  Creates a list of metadata items with icons, text, and optional highlighting.

  ## Examples

      iex> build_course_metadata(%{instructor: %{name: "John Doe"}})
      [%{icon: "hero-user", text: "Instructor: ", additional: "John Doe", highlight_additional: true}]
  """
  def build_course_metadata(course) do
    metadata = []

    # Add instructor if available
    metadata =
      if course[:instructor] do
        instructor_name = if is_map(course.instructor), do: course.instructor.name, else: course.instructor

        metadata ++
          [
            %{
              icon: "hero-user",
              text: "Instructor: ",
              additional: instructor_name,
              highlight_additional: true
            }
          ]
      else
        metadata
      end

    # Add duration if available
    metadata =
      if course[:duration] do
        metadata ++
          [
            %{
              icon: "hero-clock-circle",
              text: "Duration: ",
              additional: course.duration,
              highlight_additional: false
            }
          ]
      else
        metadata
      end

    # Add price if available and not free
    metadata =
      cond do
        course[:is_free] ->
          metadata ++
            [
              %{
                icon: "hero-currency-dollar",
                text: "Free course",
                highlight: true
              }
            ]

        course[:price] ->
          price_text = if is_integer(course.price), do: "$#{course.price}", else: course.price

          metadata ++
            [
              %{
                icon: "hero-currency-dollar",
                text: "Price: ",
                additional: price_text,
                highlight_additional: false
              }
            ]

        true ->
          metadata
      end

    metadata
  end

  @doc """
  Builds tags array for a course.

  Creates a list of tag items with icons and text for display in the UI.

  ## Examples

      iex> build_course_tags(%{level: "Beginner", last_updated: "2 days ago"})
      [
        %{icon: "hero-clock", text: "2 days ago"},
        %{icon: "hero-academic-cap", text: "Beginner"}
      ]
  """
  def build_course_tags(course) do
    tags = []

    # Add last updated if available
    tags =
      if course[:last_updated] do
        tags ++ [%{icon: "hero-clock", text: course.last_updated}]
      else
        tags ++ [%{icon: "hero-clock", text: "Updated recently"}]
      end

    # Add level if available
    tags =
      if course[:level] do
        tags ++ [%{icon: "hero-academic-cap", text: course.level}]
      else
        tags ++ [%{icon: "hero-academic-cap", text: "All Levels"}]
      end

    # Add category if available
    tags =
      if course[:category] do
        tags ++ [%{icon: "hero-tag", text: course.category}]
      else
        tags
      end

    # Add language if available and different from default
    tags =
      if course[:language] && course[:language] != "English" do
        tags ++ [%{icon: "hero-language", text: course.language}]
      else
        tags
      end

    tags
  end
end
