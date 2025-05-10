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
      class={"bg-gradient-to-br from-white to-[color:var(--color-secondary-50)]/10 dark:from-gray-800 dark:to-gray-800/95 #{@class}"}
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
  attr :compact, :boolean, default: false, doc: "Whether to display in compact gallery mode"
  attr :width_class, :string, default: "w-full", doc: "Width class for the container"
  attr :height_class, :string, default: "h-full", doc: "Height class for the container"

  def featured_course_item(assigns) do
    assigns = assign_new(assigns, :compact, fn -> false end)
    assigns = assign_new(assigns, :width_class, fn -> "w-full" end)
    assigns = assign_new(assigns, :height_class, fn -> "h-full" end)

    ~H"""
    <div
      class={"group overflow-hidden rounded-xl transition-all duration-300 hover:shadow-lg border border-[color:var(--color-primary-200)] dark:border-[color:var(--color-primary-800)]/50 bg-white dark:bg-gray-800 relative flex flex-col #{@width_class} #{@height_class} #{@class}"}
      {@rest}
    >
      <div class="flex flex-col h-full">
        <!-- Decorative top bar -->
        <div class="h-1.5 w-full bg-gradient-to-r from-[color:var(--color-primary-400)] via-[color:var(--color-primary-500)] to-[color:var(--color-primary-600)] shadow-sm">
        </div>

        <div class="relative w-full flex-shrink-0 overflow-hidden">
          <!-- Course thumbnail with overlay -->
          <div class={"#{if @compact, do: "aspect-[16/9]", else: "aspect-[21/9]"} w-full overflow-hidden"}>
            <img
              src={@course[:cover_image] || @course[:image] || "/images/default-course.jpg"}
              alt={@course.title}
              class="w-full h-full object-cover transform transition-transform duration-700 group-hover:scale-105"
              loading="lazy"
            />
            <div class="absolute inset-0 bg-gradient-to-t from-black/80 via-black/40 to-transparent">
            </div>
          </div>

          <%= if @course[:discount_percentage] do %>
            <div class={"absolute #{if @compact, do: "-right-8 top-4", else: "-right-9 top-6"} bg-gradient-to-r from-[color:var(--color-primary-600)] to-red-600 text-white px-10 py-1 transform rotate-45 shadow-lg text-xs font-bold"}>
              {@course.discount_percentage}% OFF
            </div>
          <% end %>

          <%= if @course[:is_premium] do %>
            <div class={"absolute #{if @compact, do: "top-2 left-2", else: "top-3 left-3"} flex items-center space-x-1 bg-black/40 backdrop-blur-sm rounded-full px-2 py-0.5 border border-[color:var(--color-primary-500)]/30"}>
              <.icon name="hero-sparkles" class="w-3.5 h-3.5 text-[color:var(--color-primary-400)]" />
              <span class="text-xs font-medium text-white">Premium</span>
            </div>
          <% end %>

          <%= if !@compact || @course[:rating] do %>
            <div class={"absolute bottom-0 left-0 right-0 #{if @compact, do: "p-2", else: "p-3"} flex flex-col gap-1.5"}>
              <!-- Rating -->
              <%= if @course[:rating] do %>
                <div class="flex items-center">
                  <div class="px-1.5 py-0.5 bg-gradient-to-r from-[color:var(--color-primary-500)] to-[color:var(--color-primary-600)] text-white text-xs font-bold rounded-md flex items-center shadow-sm">
                    {@course.rating || "N/A"}
                    <.icon name="hero-star" class="w-3 h-3 ml-0.5" />
                  </div>

                  <%= unless @compact do %>
                    <div class="ml-1.5 flex">
                      <%= for i <- 1..5 do %>
                        <.icon
                          name="hero-star"
                          class={"w-3 h-3 #{if i <= trunc(@course.rating || 0), do: "text-[color:var(--color-primary-400)]", else: "text-gray-400"}"}
                        />
                      <% end %>
                      <span class="ml-1 text-xs text-white">
                        ({@course.review_count || 0})
                      </span>
                    </div>
                  <% end %>
                </div>
              <% end %>

              <%= unless @compact do %>
                <div class="flex items-center gap-1.5 flex-wrap">
                  <div class="bg-white/20 backdrop-blur-sm text-white text-xs py-0.5 px-2 rounded-full border border-white/10">
                    {@course.category || "Course"}
                  </div>

                  <div class="bg-white/20 backdrop-blur-sm text-white text-xs py-0.5 px-2 rounded-full border border-white/10 flex items-center">
                    <.icon name="hero-academic-cap" class="w-3 h-3 mr-1" />
                    {@course.level || "All Levels"}
                  </div>
                </div>
              <% end %>
            </div>
          <% end %>
        </div>

        <div class={"#{if @compact, do: "p-3", else: "p-4 lg:p-5"} flex-grow flex flex-col"}>
          <!-- Course information -->
          <div>
            <!-- Course title - menor no modo compacto -->
            <h3 class={"#{if @compact, do: "text-base", else: "text-lg"} font-bold mb-1 line-clamp-2 tracking-tight text-gray-900 dark:text-white group-hover:text-[color:var(--color-primary-600)] dark:group-hover:text-[color:var(--color-primary-400)] transition-colors duration-300"}>
              {@course.title}
            </h3>

            <%= unless @compact do %>
              <p class="text-xs text-gray-500 dark:text-gray-400 mb-2 flex items-center">
                <.icon
                  name="hero-clock"
                  class="w-3 h-3 mr-1 text-[color:var(--color-primary-500)]/70 dark:text-[color:var(--color-primary-400)]/70"
                /> Updated {@course.last_updated || "Recently"}
              </p>

              <p class="text-sm text-gray-600 dark:text-gray-400 mb-4 line-clamp-2">
                {@course.description}
              </p>
            <% end %>
          </div>

          <%= if @course[:progress] do %>
            <!-- Progress bar se aplicável -->
            <div class="mb-1 flex items-center justify-between">
              <span class="text-xs font-medium text-gray-700 dark:text-gray-300">
                <%= if @compact do %>
                  Progress
                <% else %>
                  Course Progress
                <% end %>
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

            <%= unless @compact do %>
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
          <% end %>

          <%= unless @compact do %>
            <!-- Detalhes do curso - apenas se não for compacto -->
            <div class="flex flex-wrap gap-3 mb-4 mt-auto">
              <%= if @course[:duration] do %>
                <div
                  class="flex items-center bg-[color:var(--color-primary-50)] dark:bg-[color:var(--color-primary-900)]/20 px-2 py-1 rounded-md shadow-sm border border-[color:var(--color-primary-100)] dark:border-[color:var(--color-primary-800)]/30"
                  title="Course duration"
                >
                  <.icon
                    name="hero-clock"
                    class="w-3.5 h-3.5 mr-1.5 text-[color:var(--color-primary-600)] dark:text-[color:var(--color-primary-400)]"
                  />
                  <span class="text-xs font-medium text-gray-700 dark:text-gray-300">
                    {@course.duration || "Self-paced"}
                  </span>
                </div>
              <% end %>

              <%= if @course[:content_count] do %>
                <div
                  class="flex items-center bg-[color:var(--color-primary-50)] dark:bg-[color:var(--color-primary-900)]/20 px-2 py-1 rounded-md shadow-sm border border-[color:var(--color-primary-100)] dark:border-[color:var(--color-primary-800)]/30"
                  title="Content amount"
                >
                  <.icon
                    name="hero-video-camera"
                    class="w-3.5 h-3.5 mr-1.5 text-[color:var(--color-primary-600)] dark:text-[color:var(--color-primary-400)]"
                  />
                  <span class="text-xs font-medium text-gray-700 dark:text-gray-300">
                    {@course.content_count || "0"} {@course.content_type || "lectures"}
                  </span>
                </div>
              <% end %>

              <%= if @course[:enrollment_count] do %>
                <div
                  class="flex items-center bg-[color:var(--color-primary-50)] dark:bg-[color:var(--color-primary-900)]/20 px-2 py-1 rounded-md shadow-sm border border-[color:var(--color-primary-100)] dark:border-[color:var(--color-primary-800)]/30"
                  title="Total students"
                >
                  <.icon
                    name="hero-users"
                    class="w-3.5 h-3.5 mr-1.5 text-[color:var(--color-primary-600)] dark:text-[color:var(--color-primary-400)]"
                  />
                  <span class="text-xs font-medium text-gray-700 dark:text-gray-300">
                    {format_count(@course.enrollment_count || 0)} students
                  </span>
                </div>
              <% end %>
            </div>

            <%= if @course[:instructor] do %>
              <!-- Informações do instrutor -->
              <div class="flex items-center p-3 mb-4 rounded-lg bg-gray-50 dark:bg-gray-700/30 border border-gray-100 dark:border-gray-700">
                <div class="w-9 h-9 rounded-full overflow-hidden mr-3 ring-2 ring-[color:var(--color-primary-200)] dark:ring-[color:var(--color-primary-800)]/50">
                  <img
                    src={@course.instructor.avatar || "/images/default-avatar.jpg"}
                    alt={@course.instructor.name}
                    class="w-full h-full object-cover"
                  />
                </div>
                <div>
                  <p class="text-sm font-medium text-gray-900 dark:text-white flex items-center">
                    {@course.instructor.name}
                    <%= if @course.instructor[:is_verified] do %>
                      <.icon
                        name="hero-check-badge"
                        class="w-4 h-4 ml-1 text-[color:var(--color-primary-500)] dark:text-[color:var(--color-primary-400)]"
                      />
                    <% end %>
                  </p>
                  <p class="text-xs text-gray-500 dark:text-gray-400">
                    Instructor
                  </p>
                </div>
              </div>
            <% end %>
          <% else %>
            <!-- Versão compacta: apenas mostrar o nome do instrutor -->
            <%= if @course[:instructor] do %>
              <div class="flex items-center mt-1 mb-1">
                <div class="w-5 h-5 rounded-full overflow-hidden mr-1.5">
                  <img
                    src={@course.instructor.avatar || "/images/default-avatar.jpg"}
                    alt={@course.instructor.name}
                    class="w-full h-full object-cover"
                  />
                </div>
                <p class="text-xs text-gray-700 dark:text-gray-300 truncate">
                  {@course.instructor.name}
                </p>
              </div>
            <% end %>
          <% end %>

          <div class={"flex items-center justify-between mt-auto #{if @compact, do: "pt-2", else: "pt-3"} border-t border-gray-100 dark:border-gray-700"}>
            <!-- Rodapé com preço e botão - menor no modo compacto -->
            <div class="flex flex-col">
              <%= if @course[:original_price] && @course[:price] && @course.original_price > @course.price do %>
                <span class={"#{if @compact, do: "text-xs", else: "text-sm"} line-through text-gray-500 dark:text-gray-400"}>
                  ${@course.original_price}
                </span>
              <% end %>

              <span class={"#{if @compact, do: "text-base", else: "text-xl"} font-bold text-gray-900 dark:text-white"}>
                <%= if @course[:is_free] do %>
                  <span class="text-green-600 dark:text-green-400">Free</span>
                <% else %>
                  <span class="text-[color:var(--color-primary-600)] dark:text-[color:var(--color-primary-400)]">
                    ${@course.price || 0}
                  </span>
                <% end %>
              </span>
            </div>

            <.button
              color="primary"
              phx-click={@phx_click}
              phx-value-id={@course.id}
              size={if @compact, do: "xs", else: "sm"}
              class="font-medium shadow transition-all duration-300 transform group-hover:scale-105"
            >
              <%= if @course[:is_in_cart] do %>
                View in Cart <.icon name="hero-shopping-cart" class="w-4 h-4 ml-1" />
              <% else %>
                <%= if @course[:is_free] do %>
                  Enroll Now
                <% else %>
                  <%= if @course[:progress] do %>
                    Continue
                  <% else %>
                    <%= if @compact do %>
                      Add
                    <% else %>
                      Add to Cart
                    <% end %>
                  <% end %>
                <% end %>
                <.icon
                  name="hero-arrow-right"
                  class={"#{if @compact, do: "w-3.5 h-3.5", else: "w-4 h-4"} ml-1 group-hover:translate-x-0.5 transition-transform"}
                />
              <% end %>
            </.button>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp format_count(count) when is_integer(count) do
    cond do
      count >= 1_000_000 -> "#{Float.round(count / 1_000_000, 1)}M"
      count >= 1_000 -> "#{Float.round(count / 1_000, 1)}K"
      true -> to_string(count)
    end
  end

  defp format_count(_), do: "0"

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
