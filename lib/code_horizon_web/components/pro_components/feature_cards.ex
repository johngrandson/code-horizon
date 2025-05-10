defmodule CodeHorizonWeb.FeatureCards do
  @moduledoc """
  Base components for feature cards with dynamic styling based on the active template.
  Provides reusable building blocks for dashboard and content elements.
  """
  use Phoenix.Component
  use PetalComponents

  @doc """
  Renders a feature card with decorative header, icon and dynamic styling.

  ## Attributes

  * `title` - Required card title
  * `subtitle` - Optional subtitle
  * `icon` - Required icon name (hero-*)
  * `count` - Optional count badge
  * `class` - Additional CSS classes to apply
  * `action_text` - Text for action button
  * `action_path` - Path for action button
  * `action_icon` - Icon for action button
  * `min_height` - Minimum height for content

  ## Examples

      <.feature_card
        title="My Courses"
        subtitle="Your latest enrolled courses"
        icon="hero-academic-cap"
        count={5}
        action_text="View all"
        action_path={~p"/app/courses"}
      >
        Card content here
      </.feature_card>
  """
  attr :title, :string, required: true, doc: "Card title"
  attr :subtitle, :string, default: nil, doc: "Optional subtitle"
  attr :icon, :string, required: true, doc: "Icon name (hero-*)"
  attr :count, :integer, default: nil, doc: "Optional count badge"
  attr :class, :string, default: "", doc: "Additional CSS classes"
  attr :action_text, :string, default: nil, doc: "Text for action button"
  attr :action_path, :string, default: nil, doc: "Path for action button"
  attr :action_icon, :string, default: "hero-chevron-right", doc: "Icon for action button"
  attr :min_height, :string, default: "320px", doc: "Minimum height for content"
  attr :rest, :global, doc: "Additional HTML attributes"

  slot :inner_block, required: true
  slot :action, doc: "Optional slot for action button or link"

  def feature_card(assigns) do
    ~H"""
    <div
      <div
      class={"overflow-hidden shadow-md hover:shadow-lg mb-8 transition-all duration-500 border-0 rounded-xl bg-white dark:bg-gray-800 #{@class}"}
      {@rest}
    >
      <!-- Modern header with decorative element -->
      <div class="relative">
        <!-- Decorative top bar -->
        <div class="absolute top-0 left-0 right-0 h-1.5 bg-gradient-to-r from-[color:var(--color-primary-400)] via-[color:var(--color-primary-500)] to-[color:var(--color-primary-600)] shadow-sm">
        </div>

        <div class="px-6 pt-6 flex justify-between items-center">
          <div class="flex items-center space-x-3">
            <div class="relative">
              <div class={"relative flex -top-2 items-center justify-center w-10 h-10 rounded-full bg-gradient-to-br from-[color:var(--color-primary-500)] to-[color:var(--color-primary-600)] shadow-lg #{if @icon == "hero-sparkles", do: "animate-pulse"}"}>
                <.icon name={@icon} class="w-5 h-5 text-white" />
              </div>
              <%= if @icon == "hero-sparkles" do %>
                <div class="absolute inset-0 rounded-full bg-[color:var(--color-primary-500)]/20 animate-flicker opacity-60">
                </div>
              <% end %>
            </div>
            <div class="mb-4">
              <h3 class="text-xl font-bold text-gray-900 dark:text-white flex items-center">
                {@title}
                <%= if @count do %>
                  <span class="ml-2 flex items-center justify-center w-6 h-6 bg-[color:var(--color-primary-100)] dark:bg-[color:var(--color-primary-900)]/40 rounded-full text-xs font-semibold text-[color:var(--color-primary-700)] dark:text-[color:var(--color-primary-300)]">
                    {@count}
                  </span>
                <% end %>
              </h3>
              <%= if @subtitle do %>
                <p class="text-sm text-gray-500 dark:text-gray-400">
                  {@subtitle}
                </p>
              <% end %>
            </div>
          </div>
          <%= if @action_text && @action_path do %>
            <.button
              link_type="live_redirect"
              to={@action_path}
              variant="ghost"
              size="sm"
              class="font-medium text-[color:var(--color-primary-600)] hover:text-[color:var(--color-primary-700)] dark:text-[color:var(--color-primary-400)] dark:hover:text-[color:var(--color-primary-300)]"
            >
              {@action_text} <.icon name={@action_icon} class="w-4 h-4 ml-1" />
            </.button>
          <% end %>
          {render_slot(@action)}
        </div>
      </div>

      <div class="p-5" style={"min-height: #{@min_height}"}>
        {render_slot(@inner_block)}
      </div>
    </div>
    """
  end

  @doc """
  Renders an empty state with icon, title, and optional action button.

  ## Attributes

  * `title` - Required title for empty state
  * `message` - Optional descriptive message
  * `icon` - Required icon name (hero-*)
  * `button_text` - Optional text for action button
  * `button_path` - Optional path for action button
  * `button_icon` - Optional icon for action button
  * `class` - Additional CSS classes to apply

  ## Examples

      <.feature_empty_state
        title="No courses found"
        message="Try adjusting your search criteria"
        icon="hero-magnifying-glass"
        button_text="Reset filters"
        button_path={~p"/app/courses"}
      />
  """
  attr :title, :string, required: true, doc: "Empty state title"
  attr :message, :string, default: nil, doc: "Optional descriptive message"
  attr :icon, :string, required: true, doc: "Icon name (hero-*)"
  attr :button_text, :string, default: nil, doc: "Text for optional action button"
  attr :button_path, :string, default: nil, doc: "Path for optional action button"
  attr :button_icon, :string, default: nil, doc: "Optional icon for action button"
  attr :class, :string, default: "", doc: "Additional CSS classes"

  def feature_empty_state(assigns) do
    ~H"""
    <div class={"text-center py-12 px-6 bg-gray-50 dark:bg-gray-700/30 rounded-xl #{@class}"}>
      <div class="bg-[color:var(--color-primary-50)] dark:bg-[color:var(--color-primary-900)]/20 rounded-full h-20 w-20 flex items-center justify-center mx-auto mb-4 shadow-inner">
        <.icon
          name={@icon}
          class="w-10 h-10 text-[color:var(--color-primary-400)] dark:text-[color:var(--color-primary-500)]"
        />
      </div>
      <h3 class="text-lg font-medium text-gray-900 dark:text-white mb-2">
        {@title}
      </h3>
      <%= if @message do %>
        <p class="text-gray-500 dark:text-gray-400 mb-6 max-w-md mx-auto">
          {@message}
        </p>
      <% end %>
      <%= if @button_text && @button_path do %>
        <.button
          link_type="live_redirect"
          to={@button_path}
          color="primary"
          class="font-medium shadow transition-all duration-300"
        >
          <%= if @button_icon do %>
            <.icon name={@button_icon} class="w-4 h-4 mr-2" />
          <% end %>
          {@button_text}
        </.button>
      <% end %>
    </div>
    """
  end

  @doc """
  Renders a generic content item card with flexible layout and styling.
  Can be used for courses, projects, articles, assessments, or any other content type.

  ## Attributes

  * `title` - Required item title
  * `image` - Optional image URL
  * `progress` - Optional progress percentage (0-100)
  * `badge_text` - Optional badge text
  * `badge_icon` - Optional badge icon
  * `metadata` - List of metadata items to display
  * `tags` - List of tags to display
  * `action_text` - Text for action button
  * `action_icon` - Icon for action button
  * `item_id` - ID for the item (for phx-value-id)
  * `phx_click` - Phoenix click event
  * `class` - Additional CSS classes

  ## Examples

      <.content_item
        title="Introduction to Programming"
        image="/images/courses/intro-programming.jpg"
        progress={60}
        badge_text="In Progress"
        badge_icon="hero-clock"
        metadata={[
          %{icon: "hero-user", text: "Instructor: ", additional: "John Doe"},
          %{icon: "hero-clock", text: "Updated recently"}
        ]}
        tags={[
          %{icon: "hero-academic-cap", text: "Beginner"}
        ]}
        action_text="Continue"
        phx_click="explore_course"
        item_id="course-123"
      >
        <:subtitle>
          <p class="text-sm">Course description here</p>
        </:subtitle>
      </.content_item>
  """
  attr :title, :string, required: true, doc: "Item title"
  attr :image, :string, default: nil, doc: "Item image"
  attr :progress, :integer, default: nil, doc: "Optional progress (0-100)"
  attr :badge_text, :string, default: nil, doc: "Optional badge text"
  attr :badge_icon, :string, default: nil, doc: "Optional badge icon"
  attr :metadata, :list, default: [], doc: "List of metadata items to display"
  attr :tags, :list, default: [], doc: "List of tags to display"
  attr :action_text, :string, default: "View", doc: "Action button text"
  attr :action_icon, :string, default: "hero-arrow-right", doc: "Action icon"
  attr :item_id, :any, required: true, doc: "ID for the item (for phx-value-id)"
  attr :phx_click, :string, default: nil, doc: "Phoenix click event"
  attr :class, :string, default: "", doc: "Additional CSS classes"
  attr :rest, :global, doc: "Additional HTML attributes"

  slot :subtitle, doc: "Optional subtitle content"
  slot :actions, doc: "Optional custom actions"

  def content_item(assigns) do
    ~H"""
    <div
      class={"group overflow-hidden rounded-xl transition-all duration-300 hover:shadow-lg border border-gray-100 dark:border-gray-700 hover:border-[color:var(--color-primary-200)] dark:hover:border-[color:var(--color-primary-800/50)] bg-white dark:bg-gray-800 #{@class}"}
      {@rest}
    >
      <div class="grid grid-cols-1 md:grid-cols-12 gap-5 p-4">
        <%= if @image do %>
          <div class="md:col-span-3">
            <div class="rounded-lg overflow-hidden shadow-sm h-full relative">
              <img
                src={@image}
                alt={@title}
                class="h-full w-full object-cover transform transition-transform duration-700 group-hover:scale-105"
                loading="lazy"
              />
              <div class="absolute inset-0 bg-gradient-to-t from-black/50 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-300">
              </div>
            </div>
          </div>
        <% end %>

        <div class={if @image, do: "md:col-span-9", else: "md:col-span-12"}>
          <div class="flex flex-col h-full justify-between">
            <div>
              <div class="flex items-start justify-between mb-1">
                <h3 class="text-lg font-bold tracking-tight text-gray-900 dark:text-white group-hover:text-[color:var(--color-primary-600)] dark:group-hover:text-[color:var(--color-primary-400)] transition-colors duration-300 line-clamp-2">
                  {@title}
                </h3>

                <%= if @badge_text do %>
                  <div class="px-2 py-1 bg-gradient-to-r from-[color:var(--color-primary-500)] to-[color:var(--color-primary-600)] text-white text-xs font-bold rounded-md flex items-center shadow-sm">
                    <%= if @badge_icon do %>
                      <.icon name={@badge_icon} class="w-3.5 h-3.5 mr-1" />
                    <% end %>
                    {@badge_text}
                  </div>
                <% end %>
              </div>

              <%= if @subtitle != [] do %>
                <div class="mb-2">
                  {render_slot(@subtitle)}
                </div>
              <% end %>

              <%= if @progress do %>
                <div class="mb-1 flex items-center justify-between">
                  <span class="text-xs font-medium text-gray-700 dark:text-gray-300">
                    Progress
                  </span>
                  <span class="text-xs font-medium text-gray-700 dark:text-gray-300">
                    {@progress}%
                  </span>
                </div>
                <.progress
                  value={@progress}
                  class="h-2 rounded-full bg-gray-100 dark:bg-gray-700"
                  color="primary"
                />
              <% end %>
            </div>

            <%= if @metadata && length(@metadata) > 0 do %>
              <div class="mt-3">
                <%= for item <- @metadata do %>
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
            <% end %>

            <%= if @tags && length(@tags) > 0 do %>
              <div class="flex flex-wrap gap-3 my-3">
                <%= for tag <- @tags do %>
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
            <% end %>

            <div class="mt-3 flex justify-end">
              <%= if @actions != [] do %>
                {render_slot(@actions)}
              <% else %>
                <%= if @phx_click do %>
                  <.button
                    color="primary"
                    phx-click={@phx_click}
                    phx-value-id={@item_id}
                    class="font-medium shadow transition-all duration-300 transform group-hover:scale-105"
                  >
                    {@action_text}
                    <.icon
                      name={@action_icon}
                      class="w-4 h-4 ml-1 group-hover:translate-x-0.5 transition-transform"
                    />
                  </.button>
                <% end %>
              <% end %>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @doc """
  Renders a simple card without the header decoration, useful for simpler UI elements.

  ## Attributes

  * `title` - Optional card title
  * `class` - Additional CSS classes to apply
  * `padding` - Padding size (small, medium, large)
  * `shadow` - Shadow size (none, small, medium, large)
  * `hover` - Enable hover effects
  * `border` - Enable border
  * `rest` - Additional HTML attributes

  ## Examples

      <.simple_card
        title="Card Title"
        padding="large"
        shadow="medium"
        hover={true}
        border={true}
      >
        Card content here
      </.simple_card>
  """
  attr :title, :string, default: nil, doc: "Optional card title"
  attr :class, :string, default: "", doc: "Additional CSS classes"
  attr :padding, :string, default: "medium", values: ["none", "small", "medium", "large"], doc: "Padding size"
  attr :shadow, :string, default: "small", values: ["none", "small", "medium", "large"], doc: "Shadow size"
  attr :hover, :boolean, default: true, doc: "Enable hover effects"
  attr :border, :boolean, default: true, doc: "Enable border"
  attr :rest, :global, doc: "Additional HTML attributes"

  slot :inner_block, required: true
  slot :actions, doc: "Optional slot for action buttons"

  def simple_card(assigns) do
    padding_class =
      case assigns.padding do
        "none" -> "p-0"
        "small" -> "p-3"
        "large" -> "p-6"
        _ -> "p-4"
      end

    shadow_class =
      case assigns.shadow do
        "none" -> ""
        "medium" -> "shadow-md"
        "large" -> "shadow-lg"
        _ -> "shadow-sm"
      end

    hover_class =
      if assigns.hover do
        "hover:shadow-md transition-all duration-300 #{if assigns.border, do: "hover:border-[color:var(--color-primary-200)] dark:hover:border-[color:var(--color-primary-800/50)]", else: ""}"
      else
        ""
      end

    border_class =
      if assigns.border do
        "border border-gray-100 dark:border-gray-700"
      else
        ""
      end

    assigns = assign(assigns, :padding_class, padding_class)
    assigns = assign(assigns, :shadow_class, shadow_class)
    assigns = assign(assigns, :hover_class, hover_class)
    assigns = assign(assigns, :border_class, border_class)

    ~H"""
    <div
      class={[
        "rounded-xl bg-white dark:bg-gray-800",
        @padding_class,
        @shadow_class,
        @hover_class,
        @border_class,
        @class
      ]}
      {@rest}
    >
      <%= if @title do %>
        <div class="flex items-center justify-between mb-4">
          <h3 class="text-lg font-semibold text-gray-900 dark:text-white">
            {@title}
          </h3>

          <%= if @actions != [] do %>
            <div class="flex items-center space-x-2">
              {render_slot(@actions)}
            </div>
          <% end %>
        </div>
      <% end %>

      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc """
  Renders a statistics card component for numeric data display.

  ## Attributes

  * `title` - Title of the statistic
  * `value` - The numeric value or key statistic
  * `change` - Optional change value (percentage or absolute)
  * `change_type` - Type of change (increase, decrease, neutral)
  * `icon` - Optional icon to display
  * `description` - Optional description text
  * `formatter` - Function to format the value
  * `class` - Additional CSS classes

  ## Examples

      <.stat_card
        title="Total Users"
        value={1234}
        change={5.2}
        change_type="increase"
        icon="hero-users"
        description="Active users this month"
      />
  """
  attr :title, :string, required: true, doc: "Title of the statistic"
  attr :value, :any, required: true, doc: "The numeric value or key statistic"
  attr :change, :any, default: nil, doc: "Optional change value (percentage or absolute)"
  attr :change_type, :string, default: "neutral", values: ["increase", "decrease", "neutral"], doc: "Type of change"
  attr :icon, :string, default: nil, doc: "Optional icon to display"
  attr :description, :string, default: nil, doc: "Optional description text"
  attr :formatter, :any, default: &Function.identity/1, doc: "Function to format the value"
  attr :class, :string, default: "", doc: "Additional CSS classes"
  attr :rest, :global, doc: "Additional HTML attributes"

  def stat_card(assigns) do
    change_color_class =
      case assigns.change_type do
        "increase" -> "text-green-600 dark:text-green-400"
        "decrease" -> "text-red-600 dark:text-red-400"
        _ -> "text-gray-600 dark:text-gray-400"
      end

    change_icon =
      case assigns.change_type do
        "increase" -> "hero-arrow-trending-up"
        "decrease" -> "hero-arrow-trending-down"
        _ -> "hero-minus"
      end

    change_text =
      if assigns.change do
        if is_float(assigns.change) do
          sign = if assigns.change_type == "increase", do: "+", else: ""
          "#{sign}#{Float.round(assigns.change, 1)}%"
        else
          sign = if assigns.change_type == "increase", do: "+", else: ""
          "#{sign}#{assigns.change}"
        end
      end

    assigns = assign(assigns, :change_color_class, change_color_class)
    assigns = assign(assigns, :change_icon, change_icon)
    assigns = assign(assigns, :change_text, change_text)
    assigns = assign(assigns, :formatted_value, assigns.formatter.(assigns.value))

    ~H"""
    <.simple_card class={"aspect-auto lg:aspect-[3/2] #{@class}"} border={true} shadow="small" {@rest}>
      <div class="h-full flex flex-col">
        <div class="flex items-center justify-between mb-2">
          <h3 class="text-sm font-medium text-gray-500 dark:text-gray-400">
            {@title}
          </h3>
          <%= if @icon do %>
            <div class="p-1.5 rounded-md bg-[color:var(--color-primary-100)] dark:bg-[color:var(--color-primary-900/40)]">
              <.icon
                name={@icon}
                class="w-4 h-4 text-[color:var(--color-primary-600)] dark:text-[color:var(--color-primary-400)]"
              />
            </div>
          <% end %>
        </div>

        <div class="mt-1 flex items-baseline gap-2">
          <div class="text-3xl font-bold text-gray-900 dark:text-white tracking-tight">
            {@formatted_value}
          </div>
          <%= if @change_text do %>
            <div class={"flex items-center text-sm font-medium #{@change_color_class}"}>
              <.icon name={@change_icon} class="w-3.5 h-3.5 mr-1" />
              {@change_text}
            </div>
          <% end %>
        </div>

        <%= if @description do %>
          <div class="mt-auto pt-4 text-xs text-gray-500 dark:text-gray-400">
            {@description}
          </div>
        <% end %>
      </div>
    </.simple_card>
    """
  end
end
