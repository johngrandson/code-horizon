defmodule CodeHorizonWeb.TemplateComponents do
  @moduledoc false
  use Phoenix.Component
  use PetalComponents

  @doc """
  Renders a section header with gradient accent line.
  """
  attr :title, :string, required: true, doc: "Section title text"
  attr :primary_color, :string, required: true, doc: "Primary color for gradient"
  attr :accent_color, :string, required: true, doc: "Accent color for gradient"

  slot :action, doc: "Optional action element (button, link, etc.)"

  def section_header(assigns) do
    ~H"""
    <div class="flex justify-between items-center mb-6">
      <h2 class="text-xl font-semibold text-gray-900 dark:text-white flex items-center">
        <div
          class="w-1 h-6 bg-gradient-to-b rounded-full mr-2.5 shadow-sm"
          style={"background-image: linear-gradient(to bottom, #{@primary_color}, #{@accent_color})"}
        >
        </div>
        {@title}
      </h2>
      {render_slot(@action)}
    </div>
    """
  end

  @doc """
  Renders a color preview swatch with label.
  """
  attr :color, :string, required: true, doc: "Color hex code"
  attr :label, :string, required: true, doc: "Color label text"
  attr :size, :string, default: "md", doc: "Size of the color swatch (sm, md, lg)"

  def color_swatch(assigns) do
    size_class =
      case assigns.size do
        "sm" -> "w-3.5 h-3.5"
        "lg" -> "w-20 h-20"
        _ -> "w-16 h-16"
      end

    assigns = assign(assigns, :size_class, size_class)

    ~H"""
    <div>
      <div
        class={"#{@size_class} rounded-lg mb-1 shadow-md ring-2 ring-white dark:ring-gray-800"}
        style={"background-color: #{@color}"}
      >
      </div>
      <%= if @label do %>
        <p class="text-xs text-center font-medium text-gray-700 dark:text-gray-300">
          {@label}
        </p>
      <% end %>
    </div>
    """
  end

  @doc """
  Renders a badge with template-colored styling.
  """
  attr :text, :string, required: true, doc: "Badge text"
  attr :primary_color, :string, required: true, doc: "Primary color for styling"
  attr :icon, :string, default: nil, doc: "Optional icon name"
  attr :filled, :boolean, default: false, doc: "Whether badge should be filled with color"

  def template_badge(assigns) do
    ~H"""
    <span
      class={"px-2 py-1 rounded-md text-xs font-medium shadow-sm flex items-center #{if @filled, do: "text-white", else: ""}"}
      style={
        if @filled do
          "background-color: #{@primary_color}"
        else
          [
            "background-color: #{@primary_color}10",
            "border: 1px solid #{@primary_color}30",
            "color: #{@primary_color}"
          ]
        end
      }
    >
      <%= if @icon do %>
        <.icon name={@icon} class="h-3.5 w-3.5 mr-1" />
      <% end %>
      {@text}
    </span>
    """
  end

  @doc """
  Renders a template card.
  """
  attr :template, :map, required: true, doc: "Template data"
  attr :active_template, :map, required: true, doc: "Active template for styling"
  attr :current_user, :map, required: true, doc: "Current user for permission checks"
  attr :id, :string, required: true, doc: "DOM ID for the card"

  def template_card(assigns) do
    ~H"""
    <div
      id={@id}
      class="group overflow-hidden rounded-xl shadow-sm hover:shadow-lg transition-all duration-300 border border-gray-100 dark:border-gray-700 bg-white dark:bg-gray-800"
      style={@template.is_active && "border: 2px solid #{@active_template.primary_color}"}
    >
      <div
        class="aspect-video relative cursor-pointer"
        phx-click="activate"
        phx-value-id={@template.id}
      >
        <%= if @template.is_active do %>
          <div
            class="absolute top-0 left-0 right-0 h-1.5 shadow-sm z-10"
            style={"background-color: #{@active_template.primary_color}"}
          >
          </div>
        <% end %>

        <%= if @template.preview_image do %>
          <img
            src={@template.preview_image}
            alt={"Template Preview #{@template.name}"}
            class="w-full h-full object-cover transform transition-transform duration-700 group-hover:scale-105"
            loading="lazy"
          />
        <% else %>
          <div
            class="w-full h-full transition-all duration-500"
            style={"background-color: #{@template.primary_color}"}
          >
            <div class="absolute inset-0 flex items-center justify-center">
              <div
                class="w-1/2 h-1/2 rounded-lg transform transition-transform duration-500 group-hover:scale-110"
                style={"background-color: #{@template.accent_color}"}
              >
              </div>
            </div>
          </div>
        <% end %>

        <%= if @template.is_default do %>
          <div class="absolute top-4 right-4">
            <.template_badge text="Default" primary_color={@active_template.primary_color} />
          </div>
        <% end %>
      </div>

      <div class="p-5">
        <h3
          class="text-lg font-bold text-gray-900 dark:text-white transition-colors duration-300"
          style={"group-hover:color: #{@active_template.primary_color}"}
        >
          {@template.name}
        </h3>
        <p class="text-gray-600 dark:text-gray-400 text-sm mt-1 mb-4">{@template.description}</p>

        <div class="flex flex-wrap gap-3 mb-4">
          <div
            class="flex items-center px-2 py-1 rounded-md shadow-sm border"
            style={[
              "background-color: #{@active_template.primary_color}10",
              "border-color: #{@active_template.primary_color}30"
            ]}
          >
            <.icon
              name="hero-swatch"
              class="w-3.5 h-3.5 mr-1.5"
              style={"color: #{@active_template.primary_color}"}
            />
            <div class="flex space-x-2 items-center">
              <div
                class="w-3.5 h-3.5 rounded-full shadow-sm ring-1 ring-white dark:ring-gray-800"
                style={"background-color: #{@template.primary_color}"}
                title="Primary Color"
              >
              </div>
              <div
                class="w-3.5 h-3.5 rounded-full shadow-sm ring-1 ring-white dark:ring-gray-800"
                style={"background-color: #{@template.accent_color}"}
                title="Secondary Color"
              >
              </div>
            </div>
          </div>

          <%= if @template.is_active do %>
            <.template_badge
              text="Active"
              icon="hero-check"
              primary_color={@active_template.primary_color}
              filled={true}
            />
          <% end %>
        </div>

        <div class="flex justify-between pt-3 border-t border-gray-100 dark:border-gray-700">
          <%= if can_edit_template?(@current_user, @template) do %>
            <div class="flex space-x-2">
              <.themed_button variant="outline" size="sm" class="font-medium shadow-sm">
                <.icon name="hero-pencil" class="w-3.5 h-3.5 mr-1" /> Edit
              </.themed_button>

              <%= unless @template.is_active do %>
                <.themed_button
                  phx-click="delete"
                  phx-value-id={@template.id}
                  data-confirm="Are you sure you want to delete the template?"
                  variant="outline"
                  size="sm"
                  class="font-medium shadow-sm"
                >
                  <.icon name="hero-trash" class="w-3.5 h-3.5 mr-1" /> Delete
                </.themed_button>
              <% end %>
            </div>
          <% end %>

          <%= unless @template.is_active do %>
            <.themed_button
              phx-click="activate"
              phx-value-id={@template.id}
              style={"background-color: #{@active_template.primary_color}"}
              size="sm"
              class="font-medium shadow transition-all duration-300 transform group-hover:scale-105"
            >
              Activate <.icon name="hero-check-circle" class="w-3.5 h-3.5 ml-1" />
            </.themed_button>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  @doc """
  Renders the active template card with details.
  """
  attr :template, :map, required: true, doc: "Active template data"

  def active_template_card(assigns) do
    ~H"""
    <div class="mb-12 rounded-xl relative hover:shadow-md transition-all duration-500 group overflow-hidden rounded-xl shadow-sm duration-300 border border-gray-100 dark:border-gray-700 bg-white dark:bg-gray-800">
      <div class="h-1.5 w-full shadow-sm" style={"background-color: #{@template.primary_color}"}>
      </div>
      <div class="p-6">
        <div class="flex items-start justify-between mb-3.5">
          <div>
            <h2 class="text-xl font-bold text-gray-900 dark:text-white mb-2">
              {@template.name}
            </h2>
            <p class="text-gray-600 dark:text-gray-300">{@template.description}</p>
          </div>

          <div
            class="p-3 rounded-xl shadow-lg"
            style={[
              "color: #{@template.primary_color}"
            ]}
          >
            <.icon name="hero-check-circle" class="w-6 h-6" />
          </div>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mt-6">
          <div
            class="p-5 rounded-xl hover:shadow-md transition-all duration-300"
            style={[
              "border: 1px solid #{@template.primary_color}30",
              "background-image: linear-gradient(to bottom right, white, #{@template.primary_color}10)"
            ]}
          >
            <h3 class="font-medium mb-3 flex items-center">
              <.icon
                name="hero-swatch"
                class="w-4 h-4 mr-2 "
                style={[
                  "color: #{@template.primary_color}"
                ]}
              /> Color Scheme
            </h3>
            <div class="flex items-center space-x-4">
              <.color_swatch color={@template.primary_color} label="Primary" />
              <.color_swatch color={@template.accent_color} label="Secondary" />
            </div>
          </div>

          <div class="p-5 rounded-xl hover:shadow-md transition-all duration-300">
            <h3 class="font-medium mb-3 flex items-center">
              <.icon
                name="hero-eye"
                class="w-4 h-4 mr-2"
                style={[
                  "color: #{@template.primary_color}"
                ]}
              /> Visualization
            </h3>
            <div class="flex flex-wrap gap-3 mb-3">
              <button
                class="px-4 py-2 rounded-md text-white shadow-sm hover:shadow transition-all duration-300"
                style={"background-color: #{@template.primary_color}"}
              >
                Primary Button
              </button>
              <button
                class="px-4 py-2 rounded-md text-white shadow-sm hover:shadow transition-all duration-300"
                style={"background-color: #{@template.accent_color}"}
              >
                Secondary Button
              </button>
            </div>
            <div class="flex flex-wrap gap-2">
              <span
                class="px-2 py-1 rounded-md text-xs font-medium text-white shadow-sm"
                style={"background-color: #{@template.primary_color}"}
              >
                Primary Badge
              </span>
              <span
                class="px-2 py-1 rounded-md text-xs font-medium text-white shadow-sm"
                style={"background-color: #{@template.accent_color}"}
              >
                Secondary Badge
              </span>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @doc """
  A themed button that respects dynamic color variables.
  Extends PetalComponents.Button with improved theme support.
  """
  attr :class, :string, default: "", doc: "Additional classes"
  attr :variant, :string, default: "solid", values: ~w(solid outline), doc: "Button variant (solid or outline)"
  attr :color, :string, default: "primary", doc: "Color scheme"
  attr :to, :any, default: nil, doc: "LiveView or URL to link to"
  attr :link_type, :string, default: "button", values: ~w(button live_redirect live_patch href), doc: "Link type"
  attr :disabled, :boolean, default: false, doc: "Disable button"
  attr :size, :string, default: "md", values: ~w(xs sm md lg xl), doc: "Button size"
  attr :rest, :global, doc: "Additional attributes"

  slot :inner_block, required: true, doc: "Button content"

  def themed_button(assigns) do
    # Reuse existing PetalComponents.Button logic and add theme support
    themed_class = get_themed_button_class(assigns.variant, assigns.color)

    assigns = assign(assigns, :themed_class, themed_class)

    ~H"""
    <.button
      class={"#{@themed_class} #{@class}"}
      variant={@variant}
      color={@color}
      to={@to}
      link_type={@link_type}
      disabled={@disabled}
      size={@size}
      {@rest}
    >
      {render_slot(@inner_block)}
    </.button>
    """
  end

  # Functions to generate classes for buttons with dynamic colors
  defp get_themed_button_class("outline", "primary") do
    "border-[color:var(--color-primary-500)] text-[color:var(--color-primary-500)] hover:bg-[color:var(--color-primary-50)] hover:text-[color:var(--color-primary-700)] dark:border-[color:var(--color-primary-400)] dark:text-[color:var(--color-primary-400)] dark:hover:bg-[color:var(--color-primary-900/10)] dark:hover:text-[color:var(--color-primary-300)]"
  end

  defp get_themed_button_class("outline", _) do
    # Classes for other colors, keep the default
    ""
  end

  defp get_themed_button_class("solid", "primary") do
    "bg-[color:var(--color-primary-500)] hover:bg-[color:var(--color-primary-600)] text-white dark:bg-[color:var(--color-primary-600)] dark:hover:bg-[color:var(--color-primary-700)]"
  end

  defp get_themed_button_class("solid", _) do
    # Classes for other colors, keep the default
    ""
  end

  defp can_edit_template?(user, template) do
    user.role in ["admin", "super_admin"] || template.created_by_id == user.id
  end
end
