defmodule CodeHorizonWeb.QuestionOptionLive.Index do
  @moduledoc false
  use CodeHorizonWeb, :live_view

  import CodeHorizonWeb.DataTable
  import CodeHorizonWeb.PageComponents

  alias CodeHorizon.Assessments
  alias CodeHorizon.Assessments.QuestionOption

  @data_table_opts [
    default_limit: 10,
    default_order: %{
      order_by: [:id, :inserted_at],
      order_directions: [:asc, :asc]
    },
    sortable: [:id, :inserted_at, :option_text, :is_correct, :order],
    filterable: [:id, :inserted_at, :option_text, :is_correct, :order]
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
    |> assign(:page_title, "Edit Question option")
    |> assign(:question_option, Assessments.get_question_option!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Question option")
    |> assign(:question_option, %QuestionOption{})
  end

  defp apply_action(socket, :index, params) do
    socket
    |> assign(:page_title, "Listing Question options")
    |> assign_question_options(params)
    |> assign(index_params: params)
  end

  defp current_index_path(index_params) do
    ~p"/app/question_options?#{index_params || %{}}"
  end

  @impl true
  def handle_event("update_filters", params, socket) do
    query_params = CodeHorizonWeb.DataTable.build_filter_params(socket.assigns.meta.flop, params)
    {:noreply, push_patch(socket, to: ~p"/app/question_options?#{query_params}")}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    question_option = Assessments.get_question_option!(id)
    {:ok, _} = Assessments.delete_question_option(question_option)

    socket =
      socket
      |> assign_question_options(socket.assigns.index_params)
      |> put_flash(:info, "Question option deleted")

    {:noreply, socket}
  end

  @impl true
  def handle_event("close_modal", _, socket) do
    {:noreply, push_patch(socket, to: current_index_path(socket.assigns.index_params))}
  end

  defp assign_question_options(socket, params) do
    starting_query = QuestionOption
    {question_options, meta} = CodeHorizonWeb.DataTable.search(starting_query, params, @data_table_opts)
    assign(socket, question_options: question_options, meta: meta)
  end
end
