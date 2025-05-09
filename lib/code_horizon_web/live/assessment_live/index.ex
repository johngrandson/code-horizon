defmodule CodeHorizonWeb.AssessmentLive.Index do
  @moduledoc false
  use CodeHorizonWeb, :live_view

  import CodeHorizonWeb.DataTable
  import CodeHorizonWeb.PageComponents

  alias CodeHorizon.Assessments
  alias CodeHorizon.Assessments.Assessment

  @data_table_opts [
    default_limit: 10,
    default_order: %{
      order_by: [:id, :inserted_at],
      order_directions: [:asc, :asc]
    },
    sortable: [
      :id,
      :inserted_at,
      :title,
      :description,
      :passing_score,
      :max_attempts,
      :time_limit_minutes,
      :assessment_type,
      :is_published
    ],
    filterable: [
      :id,
      :inserted_at,
      :title,
      :description,
      :passing_score,
      :max_attempts,
      :time_limit_minutes,
      :assessment_type,
      :is_published
    ]
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
    |> assign(:page_title, "Edit Assessment")
    |> assign(:assessment, Assessments.get_assessment!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Assessment")
    |> assign(:assessment, %Assessment{})
  end

  defp apply_action(socket, :index, params) do
    socket
    |> assign(:page_title, "Listing Assessments")
    |> assign_assessments(params)
    |> assign(index_params: params)
  end

  defp current_index_path(index_params) do
    ~p"/app/assessments?#{index_params || %{}}"
  end

  @impl true
  def handle_event("update_filters", params, socket) do
    query_params = CodeHorizonWeb.DataTable.build_filter_params(socket.assigns.meta.flop, params)
    {:noreply, push_patch(socket, to: ~p"/app/assessments?#{query_params}")}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    assessment = Assessments.get_assessment!(id)
    {:ok, _} = Assessments.delete_assessment(assessment)

    socket =
      socket
      |> assign_assessments(socket.assigns.index_params)
      |> put_flash(:info, "Assessment deleted")

    {:noreply, socket}
  end

  @impl true
  def handle_event("close_modal", _, socket) do
    {:noreply, push_patch(socket, to: current_index_path(socket.assigns.index_params))}
  end

  defp assign_assessments(socket, params) do
    starting_query = Assessment
    {assessments, meta} = CodeHorizonWeb.DataTable.search(starting_query, params, @data_table_opts)
    assign(socket, assessments: assessments, meta: meta)
  end
end
