defmodule CodeHorizonWeb.TemplateLive.Index do
  @moduledoc """
  Renders the list of templates.
  """
  use CodeHorizonWeb, :live_view

  import CodeHorizonWeb.TemplateComponents

  alias CodeHorizon.Templates
  alias CodeHorizon.Templates.Template

  @impl true
  def mount(_params, _session, socket) do
    current_user = socket.assigns.current_user

    {:ok,
     socket
     |> assign(:page_title, "Templates")
     |> stream(:templates, Templates.list_templates_for_user(current_user))
     |> assign(:active_template, Templates.get_active_template_for_user(current_user))}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    template = Templates.get_template!(id)

    if can_edit_template?(socket.assigns.current_user, template) do
      socket
      |> assign(:page_title, "Edit Template")
      |> assign(:template, template)
    else
      socket
      |> put_flash(:error, "You do not have permission to edit this template")
      |> push_patch(to: ~p"/app/templates")
    end

    socket
    |> assign(:page_title, "Edit Template")
    |> assign(:template, Templates.get_template!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Template")
    |> assign(:template, %Template{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Templates")
    |> assign(:template, nil)
  end

  @impl true
  def handle_info({CodeHorizonWeb.TemplateLive.FormComponent, {:saved, template}}, socket) do
    {:noreply, stream_insert(socket, :templates, template)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    template = Templates.get_template!(id)

    if can_edit_template?(socket.assigns.current_user, template) do
      {:ok, _} = Templates.delete_template(template)

      {:noreply,
       socket
       |> put_flash(:info, "Template deleted successfully")
       |> stream_delete(:templates, template)}
    else
      socket
      |> put_flash(:error, "You do not have permission to delete this template")
      |> push_patch(to: ~p"/app/templates")
    end
  end

  def handle_event("activate", %{"id" => id}, socket) do
    template = Templates.get_template!(id)
    current_user = socket.assigns.current_user

    case Templates.set_active_template_for_user(current_user, template) do
      {:ok, _} ->
        templates = Templates.list_templates_for_user(current_user)
        active_template = Templates.get_active_template_for_user(current_user)

        socket =
          socket
          |> put_flash(:info, "Template #{template.name} activated successfully")
          |> stream(:templates, templates)
          |> assign(:active_template, active_template)
          |> apply_template_style(template)

        {:noreply, socket}

      {:error, changeset} ->
        error_message = format_error_message(changeset)
        {:noreply, put_flash(socket, :error, error_message)}
    end
  end

  def handle_event("open_modal", _params, socket) do
    template = %Template{}

    {:noreply,
     socket
     |> assign(:live_action, :new)
     |> assign(:template, template)
     |> assign(:page_title, "New Template")}
  end

  @impl true
  def handle_event("close_modal", _, socket) do
    {:noreply, push_patch(socket, to: ~p"/app/templates")}
  end

  # Private functions

  defp apply_template_style(socket, template) do
    theme = if(template.is_dark_theme, do: "dark", else: "light")

    socket
    |> push_event("theme-change", %{
      theme: theme,
      primary_color: template.primary_color,
      accent_color: template.accent_color
    })
    |> push_event("apply-template", %{
      css_variables: Template.to_css_variables(template)
    })
  end

  defp format_error_message(changeset) do
    "Error activating template: #{inspect(changeset.errors)}"
  end

  defp can_edit_template?(user, template) do
    # Only the template creator can edit it
    not is_nil(template.created_by_id) and template.created_by_id == user.id
  end
end
