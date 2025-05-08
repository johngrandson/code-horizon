defmodule CodeHorizonWeb.AdminFilesLive.FilesComponent do
  @moduledoc false
  use CodeHorizonWeb, :live_component

  alias CodeHorizon.Files

  @impl true
  def update(assigns, socket) do
    {:ok, assign(socket, assigns)}
  end

  @impl true
  def handle_event("archive", %{"id" => file_id}, socket) do
    file = Files.get_file!(file_id)

    case Files.archive_file(file) do
      {:ok, _file} ->
        notify_parent(:file_archived)

        {:noreply, put_flash(socket, :info, gettext("File archived"))}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, gettext("Problem archiving file"))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
