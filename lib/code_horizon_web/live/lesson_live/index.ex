defmodule CodeHorizonWeb.LessonLive.Index do
  @moduledoc false
  use CodeHorizonWeb, :live_view

  import CodeHorizonWeb.DataTable
  import CodeHorizonWeb.PageComponents

  alias CodeHorizon.Lessons
  alias CodeHorizon.Lessons.Lesson

  @data_table_opts [
    default_limit: 10,
    default_order: %{
      order_by: [:id, :inserted_at],
      order_directions: [:asc, :asc]
    },
    sortable: [:id, :inserted_at, :title, :content, :order],
    filterable: [:id, :inserted_at, :title, :content, :order]
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
    |> assign(:page_title, "Edit Lesson")
    |> assign(:lesson, Lessons.get_lesson!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Lesson")
    |> assign(:lesson, %Lesson{})
  end

  defp apply_action(socket, :index, params) do
    socket
    |> assign(:page_title, "Listing Lessons")
    |> assign_lessons(params)
    |> assign(index_params: params)
  end

  defp current_index_path(index_params) do
    ~p"/app/lessons?#{index_params || %{}}"
  end

  @impl true
  def handle_event("update_filters", params, socket) do
    query_params = CodeHorizonWeb.DataTable.build_filter_params(socket.assigns.meta.flop, params)
    {:noreply, push_patch(socket, to: ~p"/app/lessons?#{query_params}")}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    lesson = Lessons.get_lesson!(id)
    {:ok, _} = Lessons.delete_lesson(lesson)

    socket =
      socket
      |> assign_lessons(socket.assigns.index_params)
      |> put_flash(:info, "Lesson deleted")

    {:noreply, socket}
  end

  @impl true
  def handle_event("close_modal", _, socket) do
    {:noreply, push_patch(socket, to: current_index_path(socket.assigns.index_params))}
  end

  defp assign_lessons(socket, params) do
    starting_query = Lesson
    {lessons, meta} = CodeHorizonWeb.DataTable.search(starting_query, params, @data_table_opts)
    assign(socket, lessons: lessons, meta: meta)
  end
end
