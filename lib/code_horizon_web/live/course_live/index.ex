defmodule CodeHorizonWeb.CourseLive.Index do
  @moduledoc false
  use CodeHorizonWeb, :live_view

  import CodeHorizonWeb.DataTable
  import CodeHorizonWeb.PageComponents

  alias CodeHorizon.Courses
  alias CodeHorizon.Courses.Course

  @data_table_opts [
    default_limit: 10,
    default_order: %{
      order_by: [:id, :inserted_at],
      order_directions: [:asc, :asc]
    },
    sortable: [:id, :inserted_at, :title, :description, :level, :is_published, :featured_order, :slug],
    filterable: [:id, :inserted_at, :title, :description, :level, :is_published, :featured_order, :slug]
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
    |> assign(:page_title, "Edit Course")
    |> assign(:course, Courses.get_course!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Course")
    |> assign(:course, %Course{})
  end

  defp apply_action(socket, :index, params) do
    socket
    |> assign(:page_title, "Listing Courses")
    |> assign_courses(params)
    |> assign(index_params: params)
  end

  defp current_index_path(index_params) do
    ~p"/app/courses?#{index_params || %{}}"
  end

  @impl true
  def handle_event("update_filters", params, socket) do
    query_params = CodeHorizonWeb.DataTable.build_filter_params(socket.assigns.meta.flop, params)
    {:noreply, push_patch(socket, to: ~p"/app/courses?#{query_params}")}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    course = Courses.get_course!(id)
    {:ok, _} = Courses.delete_course(course)

    socket =
      socket
      |> assign_courses(socket.assigns.index_params)
      |> put_flash(:info, "Course deleted")

    {:noreply, socket}
  end

  @impl true
  def handle_event("close_modal", _, socket) do
    {:noreply, push_patch(socket, to: current_index_path(socket.assigns.index_params))}
  end

  defp assign_courses(socket, params) do
    starting_query = Course
    {courses, meta} = CodeHorizonWeb.DataTable.search(starting_query, params, @data_table_opts)
    assign(socket, courses: courses, meta: meta)
  end
end
