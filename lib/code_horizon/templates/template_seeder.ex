defmodule CodeHorizon.Templates.TemplateSeeder do
  @moduledoc false

  import Ecto.Query, warn: false

  alias CodeHorizon.Repo
  alias CodeHorizon.Templates.Template

  @doc """
  Seeds default templates for the system
  """
  def seed_default_templates do
    templates = [
      %{
        name: "Google",
        description: "Clean, colorful and user-friendly interface",
        primary_color: "#4285F4",
        accent_color: "#EA4335",
        is_default: true,
        preview_image: "/images/templates/google.png"
      },
      %{
        name: "Discord",
        description: "Dark theme with vibrant accents",
        primary_color: "#36393F",
        accent_color: "#5865F2",
        is_default: false,
        preview_image: "/images/templates/discord.png"
      },
      %{
        name: "Slack",
        description: "Professional and collaborative interface",
        primary_color: "#4A154B",
        accent_color: "#2EB67D",
        is_default: false,
        preview_image: "/images/templates/slack.png"
      },
      %{
        name: "Salesforce",
        description: "Enterprise-grade business interface",
        primary_color: "#0176D3",
        accent_color: "#1AB9FF",
        is_default: false,
        preview_image: "/images/templates/salesforce.png"
      }
    ]

    # Create if not exists
    Enum.each(templates, fn template_attrs ->
      case Repo.get_by(Template, name: template_attrs.name) do
        nil ->
          %Template{}
          |> Template.changeset(template_attrs)
          |> Repo.insert()

        _ ->
          # Template already exists, do nothing
          :ok
      end
    end)
  end
end
