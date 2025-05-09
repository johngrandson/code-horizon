defmodule CodeHorizonWeb.AssessmentAttemptLive.Show do
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
     |> assign(:assessment_attempt, Assessments.get_assessment_attempt!(id))}
  end

  @impl true
  def handle_event("close_modal", _, socket) do
    {:noreply, push_patch(socket, to: ~p"/app/assessment_attempts/#{socket.assigns.assessment_attempt}")}
  end

  defp page_title(:show), do: "Show Assessment attempt"
  defp page_title(:edit), do: "Edit Assessment attempt"
end
