defmodule CodeHorizonWeb.QuestionLive.Index do
  @moduledoc false
  use CodeHorizonWeb, :live_view

  import CodeHorizonWeb.DataTable
  import CodeHorizonWeb.PageComponents

  alias CodeHorizon.Assessments
  alias CodeHorizon.Assessments.Question

  @data_table_opts [
    default_limit: 10,
    default_order: %{
      order_by: [:id, :inserted_at],
      order_directions: [:asc, :asc]
    },
    sortable: [:id, :inserted_at, :question_text, :question_type, :points, :order],
    filterable: [:id, :inserted_at, :question_text, :question_type, :points, :order]
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
    |> assign(:page_title, "Edit Question")
    |> assign(:question, Assessments.get_question!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Question")
    |> assign(:question, %Question{})
  end

  defp apply_action(socket, :index, params) do
    socket
    |> assign(:page_title, "Listing Questions")
    |> assign_questions(params)
    |> assign(index_params: params)
  end

  defp current_index_path(index_params) do
    ~p"/app/questions?#{index_params || %{}}"
  end

  @impl true
  def handle_event("update_filters", params, socket) do
    query_params = CodeHorizonWeb.DataTable.build_filter_params(socket.assigns.meta.flop, params)
    {:noreply, push_patch(socket, to: ~p"/app/questions?#{query_params}")}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    question = Assessments.get_question!(id)
    {:ok, _} = Assessments.delete_question(question)

    socket =
      socket
      |> assign_questions(socket.assigns.index_params)
      |> put_flash(:info, "Question deleted")

    {:noreply, socket}
  end

  @impl true
  def handle_event("close_modal", _, socket) do
    {:noreply, push_patch(socket, to: current_index_path(socket.assigns.index_params))}
  end

  defp assign_questions(socket, params) do
    starting_query = Question
    {questions, meta} = CodeHorizonWeb.DataTable.search(starting_query, params, @data_table_opts)
    assign(socket, questions: questions, meta: meta)
  end
end
