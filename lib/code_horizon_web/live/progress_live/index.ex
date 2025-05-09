defmodule CodeHorizonWeb.ProgressLive.Index do
  @moduledoc false
  use CodeHorizonWeb, :live_view

  import CodeHorizonWeb.DataTable
  import CodeHorizonWeb.PageComponents

  alias CodeHorizon.ProgressTracking
  alias CodeHorizon.ProgressTracking.Progress

  @data_table_opts [
    default_limit: 10,
    default_order: %{
      order_by: [:id, :inserted_at],
      order_directions: [:asc, :asc]
    },
    sortable: [:id, :inserted_at, :completion_status, :percent_complete, :last_accessed_at, :completion_date],
    filterable: [:id, :inserted_at, :completion_status, :percent_complete, :last_accessed_at, :completion_date]
  ]

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, index_params: nil)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Progress")
    |> assign(:progress, ProgressTracking.get_progress!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Progress")
    |> assign(:progress, %Progress{})
  end

  defp apply_action(socket, :index, params) do
    socket
    |> assign(:page_title, "Listing Progress")
    |> assign_progress(params)
    |> assign(index_params: params)
  end

  defp current_index_path(index_params) do
    ~p"/app/progress?#{index_params || %{}}"
  end

  @impl true
  def handle_event("update_filters", params, socket) do
    query_params = CodeHorizonWeb.DataTable.build_filter_params(socket.assigns.meta.flop, params)
    {:noreply, push_patch(socket, to: ~p"/app/progress?#{query_params}")}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    progress = ProgressTracking.get_progress!(id)
    {:ok, _} = ProgressTracking.delete_progress(progress)

    socket =
      socket
      |> assign_progress(socket.assigns.index_params)
      |> put_flash(:info, "Progress deleted")

    {:noreply, socket}
  end

  @impl true
  def handle_event("close_modal", _, socket) do
    {:noreply, push_patch(socket, to: current_index_path(socket.assigns.index_params))}
  end

  defp assign_progress(socket, params) do
    starting_query = Progress
    {progress, meta} = CodeHorizonWeb.DataTable.search(starting_query, params, @data_table_opts)
    assign(socket, progress: progress, meta: meta)
  end
end
