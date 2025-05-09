defmodule CodeHorizonWeb.AssessmentAttemptLive.Index do
  @moduledoc false
  use CodeHorizonWeb, :live_view

  import CodeHorizonWeb.DataTable
  import CodeHorizonWeb.PageComponents

  alias CodeHorizon.Assessments
  alias CodeHorizon.Assessments.AssessmentAttempt

  @data_table_opts [
    default_limit: 10,
    default_order: %{
      order_by: [:id, :inserted_at],
      order_directions: [:asc, :asc]
    },
    sortable: [:id, :inserted_at, :score, :status, :start_time, :end_time],
    filterable: [:id, :inserted_at, :score, :status, :start_time, :end_time]
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
    |> assign(:page_title, "Edit Assessment attempt")
    |> assign(:assessment_attempt, Assessments.get_assessment_attempt!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Assessment attempt")
    |> assign(:assessment_attempt, %AssessmentAttempt{})
  end

  defp apply_action(socket, :index, params) do
    socket
    |> assign(:page_title, "Listing Assessment attempts")
    |> assign_assessment_attempts(params)
    |> assign(index_params: params)
  end

  defp current_index_path(index_params) do
    ~p"/app/assessment_attempts?#{index_params || %{}}"
  end

  @impl true
  def handle_event("update_filters", params, socket) do
    query_params = CodeHorizonWeb.DataTable.build_filter_params(socket.assigns.meta.flop, params)
    {:noreply, push_patch(socket, to: ~p"/app/assessment_attempts?#{query_params}")}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    assessment_attempt = Assessments.get_assessment_attempt!(id)
    {:ok, _} = Assessments.delete_assessment_attempt(assessment_attempt)

    socket =
      socket
      |> assign_assessment_attempts(socket.assigns.index_params)
      |> put_flash(:info, "Assessment attempt deleted")

    {:noreply, socket}
  end

  @impl true
  def handle_event("close_modal", _, socket) do
    {:noreply, push_patch(socket, to: current_index_path(socket.assigns.index_params))}
  end

  defp assign_assessment_attempts(socket, params) do
    starting_query = AssessmentAttempt
    {assessment_attempts, meta} = CodeHorizonWeb.DataTable.search(starting_query, params, @data_table_opts)
    assign(socket, assessment_attempts: assessment_attempts, meta: meta)
  end
end
