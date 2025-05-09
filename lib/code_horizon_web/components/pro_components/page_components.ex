defmodule CodeHorizonWeb.PageComponents do
  @moduledoc false
  use Phoenix.Component
  use PetalComponents

  @doc """
  Allows you to have a heading on the left side, and some action buttons on the right (default slot)
  """

  attr :icon, :string, default: nil
  attr :class, :string, default: ""
  attr :title, :string, required: true
  slot(:inner_block)

  def page_header(assigns) do
    assigns = assign_new(assigns, :inner_block, fn -> nil end)

    ~H"""
    <div class={["mb-8 sm:flex sm:justify-between sm:items-center", @class]}>
      <div class="mb-4 sm:mb-0 flex gap-2 items-center">
        <.icon :if={@icon} name={@icon} class="w-10 h-10" />
        <.h2 class="!mb-0">
          {@title}
        </.h2>
      </div>

      <div class="flex gap-2 items-center">
        <%= if @inner_block do %>
          {render_slot(@inner_block)}
        <% end %>
      </div>
    </div>
    """
  end

  @doc "Gives you a white background with shadow."
  attr :class, :string, default: ""
  attr :padded, :boolean, default: false
  attr :rest, :global
  slot(:inner_block)

  def box(assigns) do
    ~H"""
    <div
      {@rest}
      class={[
        "bg-white dark:bg-gray-800 dark:border dark:border-gray-700 rounded-lg shadow-sm overflow-hidden",
        @class,
        if(@padded, do: "px-4 py-8 sm:px-10", else: "")
      ]}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc """
  Provides a container with a sidebar on the left and main content on the right. Useful for things like user settings.

  ---------------------------------
  | Sidebar | Main                |
  |         |                     |
  |         |                     |
  |         |                     |
  ---------------------------------
  """

  attr :current_page, :atom

  attr :menu_items, :list,
    required: true,
    doc: "list of maps with keys :name, :path, :label, :icon (heroicon class)"

  slot(:inner_block)

  def sidebar_tabs_container(assigns) do
    ~H"""
    <.box class="flex flex-col border border-gray-200 divide-y divide-gray-200 dark:border-none dark:divide-gray-700 md:divide-y-0 md:divide-x md:flex-row">
      <div class="shrink-0 w-full py-6 md:w-72">
        <%= for menu_item <- @menu_items do %>
          <.sidebar_menu_item current={@current_page} {menu_item} />
        <% end %>
      </div>

      <div class="grow px-4 py-6 sm:p-6 lg:pb-8">
        {render_slot(@inner_block)}
      </div>
    </.box>
    """
  end

  attr :current, :atom
  attr :name, :string
  attr :path, :string
  attr :label, :string
  attr :icon, :string

  def sidebar_menu_item(assigns) do
    assigns = assign(assigns, :is_active?, assigns.current == assigns.name)

    ~H"""
    <.link
      navigate={@path}
      class={[
        menu_item_classes(@is_active?),
        "flex items-center px-3 py-2 text-sm font-medium border-transparent group"
      ]}
    >
      <.icon name={@icon} class={menu_item_icon_classes(@is_active?) <> " shrink-0 w-6 h-6 mx-3"} />
      <div>
        {@label}
      </div>
    </.link>
    """
  end

  def stat_card(assigns) do
    ~H"""
    <div class="bg-white dark:bg-gray-800 rounded-lg shadow p-4">
      <div class="flex items-center justify-between mb-2">
        <h3 class="text-sm font-medium text-gray-500 dark:text-gray-400">{@title}</h3>
        <div class={"bg-#{@color}-100 text-#{@color}-600 p-1.5 rounded-full"}>
          <.icon name={@icon} class="w-4 h-4" />
        </div>
      </div>
      <p class="text-2xl font-semibold">{@value}</p>
    </div>
    """
  end

  def section_card(assigns) do
    assigns = assign_new(assigns, :class, fn -> "" end)

    ~H"""
    <div class={"bg-white dark:bg-gray-800 rounded-lg shadow p-5 #{@class}"}>
      <div class="flex items-center mb-4">
        <.icon name={@icon} class="w-5 h-5 mr-2 text-primary-500" />
        <h2 class="text-lg font-semibold">{@title}</h2>
      </div>
      {render_slot(@inner_block)}
    </div>
    """
  end

  def page_empty_state(assigns) do
    ~H"""
    <div class="py-6 flex flex-col items-center justify-center text-center">
      <div class="bg-gray-100 dark:bg-gray-700 rounded-full p-3 mb-3">
        <.icon name="hero-information-circle" class="w-5 h-5 text-gray-400" />
      </div>
      <h3 class="font-medium mb-1">{@title}</h3>
      <p class="text-sm text-gray-500 dark:text-gray-400">{@description}</p>
    </div>
    """
  end

  @doc """
  Renders a metric card with an icon, title and value.

  ## Examples
      <.metric_card
        title="Cursos Concluídos"
        value={10}
        icon_name="hero-check-circle"
        icon_color_class="text-emerald-500 bg-emerald-100"
      />
  """
  attr :title, :string, required: true, doc: "The title of the metric"
  attr :value, :any, required: true, doc: "The value to display"
  attr :icon_name, :string, required: true, doc: "The name of the icon to display"
  attr :icon_color_class, :string, default: "text-primary-500 bg-primary-100", doc: "CSS classes for the icon color"

  def metric_card(assigns) do
    ~H"""
    <div class="bg-white dark:bg-gray-800 rounded-lg shadow p-5 h-full">
      <div class="flex items-center justify-between mb-2">
        <h3 class="text-sm font-medium text-gray-500 dark:text-gray-400">{@title}</h3>
        <div class={"rounded-full p-2 flex items-center justify-center #{@icon_color_class}"}>
          <.icon name={@icon_name} class="w-4 h-4" />
        </div>
      </div>
      <p class="text-2xl font-bold">{@value}</p>
    </div>
    """
  end

  defp menu_item_classes(true),
    do: "bg-gray-100 border-gray-500 text-gray-700 dark:bg-gray-700 dark:text-gray-100 dark:hover:text-white"

  defp menu_item_classes(false),
    do:
      "text-gray-900 hover:bg-gray-50 hover:text-gray-900 dark:text-gray-400 dark:hover:bg-gray-700/70 dark:hover:text-gray-50"

  defp menu_item_icon_classes(true),
    do: "text-gray-500 group-hover:text-gray-500 dark:text-gray-100 dark:group-hover:text-white"

  defp menu_item_icon_classes(false),
    do: "text-gray-500 group-hover:text-gray-500 dark:text-gray-400 dark:group-hover:text-gray-400"
end
