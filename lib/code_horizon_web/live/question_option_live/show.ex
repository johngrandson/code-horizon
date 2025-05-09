defmodule CodeHorizonWeb.QuestionOptionLive.Show do
  @moduledoc false
  use CodeHorizonWeb, :live_view

  import CodeHorizonWeb.PageComponents

  alias CodeHorizon.Assessments

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:question_option, Assessments.get_question_option!(id))}
  end

  @impl true
  def handle_event("close_modal", _, socket) do
    {:noreply, push_patch(socket, to: ~p"/app/question_options/#{socket.assigns.question_option}")}
  end

  defp page_title(:show), do: "Show Question option"
  defp page_title(:edit), do: "Edit Question option"
end
