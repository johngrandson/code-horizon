defmodule CodeHorizonWeb.AttemptAnswerLive.Index do
  @moduledoc false
  use CodeHorizonWeb, :live_view

  import CodeHorizonWeb.DataTable
  import CodeHorizonWeb.PageComponents

  alias CodeHorizon.Assessments
  alias CodeHorizon.Assessments.AttemptAnswer

  @data_table_opts [
    default_limit: 10,
    default_order: %{
      order_by: [:id, :inserted_at],
      order_directions: [:asc, :asc]
    },
    sortable: [:id, :inserted_at, :answer_text, :is_correct, :points_awarded],
    filterable: [:id, :inserted_at, :answer_text, :is_correct, :points_awarded]
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
    |> assign(:page_title, "Edit Attempt answer")
    |> assign(:attempt_answer, Assessments.get_attempt_answer!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Attempt answer")
    |> assign(:attempt_answer, %AttemptAnswer{})
  end

  defp apply_action(socket, :index, params) do
    socket
    |> assign(:page_title, "Listing Attempt answers")
    |> assign_attempt_answers(params)
    |> assign(index_params: params)
  end

  defp current_index_path(index_params) do
    ~p"/app/attempt_answers?#{index_params || %{}}"
  end

  @impl true
  def handle_event("update_filters", params, socket) do
    query_params = CodeHorizonWeb.DataTable.build_filter_params(socket.assigns.meta.flop, params)
    {:noreply, push_patch(socket, to: ~p"/app/attempt_answers?#{query_params}")}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    attempt_answer = Assessments.get_attempt_answer!(id)
    {:ok, _} = Assessments.delete_attempt_answer(attempt_answer)

    socket =
      socket
      |> assign_attempt_answers(socket.assigns.index_params)
      |> put_flash(:info, "Attempt answer deleted")

    {:noreply, socket}
  end

  @impl true
  def handle_event("close_modal", _, socket) do
    {:noreply, push_patch(socket, to: current_index_path(socket.assigns.index_params))}
  end

  defp assign_attempt_answers(socket, params) do
    starting_query = AttemptAnswer
    {attempt_answers, meta} = CodeHorizonWeb.DataTable.search(starting_query, params, @data_table_opts)
    assign(socket, attempt_answers: attempt_answers, meta: meta)
  end
end
