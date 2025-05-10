defmodule CodeHorizon.Templates.Template do
  @moduledoc false
  use CodeHorizon.Schema

  typed_schema "templates" do
    field :name, :string
    field :description, :string
    field :primary_color, :string
    field :accent_color, :string
    field :preview_image, :string, default: "/images/templates/default.png"
    field :is_dark_theme, :boolean, default: false
    field :is_default, :boolean, default: false
    field :is_active, :boolean, virtual: true, default: false

    belongs_to :created_by, CodeHorizon.Accounts.User

    has_many :user_templates, CodeHorizon.Templates.UserTemplate
    has_many :users, through: [:user_templates, :user]

    timestamps()
  end

  @doc false
  def changeset(template, attrs) do
    template
    |> cast(attrs, [
      :name,
      :description,
      :preview_image,
      :primary_color,
      :accent_color,
      :is_dark_theme,
      :is_default
    ])
    |> validate_required([:name, :description, :primary_color, :accent_color, :is_default])
  end

  @doc """
  Generates CSS variables for this template
  """
  def to_css_variables(template) do
    %{
      "--primary-color": template.primary_color,
      "--accent-color": template.accent_color,
      "--primary-color-rgb": hex_to_rgb(template.primary_color),
      "--accent-color-rgb": hex_to_rgb(template.accent_color)
    }
  end

  @doc """
  Convert hex color to RGB format (e.g. "255, 99, 71")
  """
  def hex_to_rgb(hex_color) do
    hex = String.replace(hex_color || "#FFFFFF", "#", "")

    r = hex |> String.slice(0, 2) |> String.to_integer(16)
    g = hex |> String.slice(2, 2) |> String.to_integer(16)
    b = hex |> String.slice(4, 2) |> String.to_integer(16)

    "#{r}, #{g}, #{b}"
  end
end
