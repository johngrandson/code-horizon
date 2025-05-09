defmodule CodeHorizonWeb.ProgressLive.FormComponent do
  use CodeHorizonWeb, :live_component

  alias CodeHorizon.ProgressTracking

  @impl true
  def update(%{progress: progress} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
      to_form(ProgressTracking.change_progress(progress))
     end)}
  end

  @impl true
  def handle_event("validate", %{"progress" => progress_params}, socket) do
    changeset =
      socket.assigns.progress
      |> ProgressTracking.change_progress(progress_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, form: to_form(changeset))}
  end

  def handle_event("save", %{"progress" => progress_params}, socket) do
    save_progress(socket, socket.assigns.action, progress_params)
  end

  defp save_progress(socket, :edit, progress_params) do
    case ProgressTracking.update_progress(socket.assigns.progress, progress_params) do
      {:ok, _progress} ->
        {:noreply,
         socket
         |> put_flash(:info, "Progress updated successfully")
         |> push_navigate(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_progress(socket, :new, progress_params) do
    case ProgressTracking.create_progress(progress_params) do
      {:ok, _progress} ->
        {:noreply,
         socket
         |> put_flash(:info, "Progress created successfully")
         |> push_navigate(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
end
