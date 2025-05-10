defmodule CodeHorizonWeb.RestoreThemeHook do
  @moduledoc false
  import Phoenix.LiveView

  alias CodeHorizon.Templates

  # Adds the theme to the socket
  def on_mount(:default, params, session, socket) do
    on_mount(:ensure_theme, params, session, socket)
  end

  def on_mount(:ensure_theme, _params, _session, socket) do
    if connected?(socket) && socket.assigns[:current_user] do
      current_user = socket.assigns.current_user
      active_template = Templates.get_active_template_for_user(current_user)

      socket =
        if active_template do
          push_event(socket, "theme-change", %{
            theme: if(active_template.is_dark_theme, do: "dark", else: "light"),
            primary_color: active_template.primary_color,
            accent_color: active_template.accent_color
          })
        else
          socket
        end

      {:cont, socket}
    else
      {:cont, socket}
    end
  end
end
