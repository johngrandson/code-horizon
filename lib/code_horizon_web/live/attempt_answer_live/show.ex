defmodule CodeHorizonWeb.AttemptAnswerLive.Show do
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
     |> assign(:attempt_answer, Assessments.get_attempt_answer!(id))}
  end

  @impl true
  def handle_event("close_modal", _, socket) do
    {:noreply, push_patch(socket, to: ~p"/app/attempt_answers/#{socket.assigns.attempt_answer}")}
  end

  defp page_title(:show), do: "Show Attempt answer"
  defp page_title(:edit), do: "Edit Attempt answer"
end
