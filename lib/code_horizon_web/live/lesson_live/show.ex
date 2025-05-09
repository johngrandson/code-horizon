defmodule CodeHorizonWeb.LessonLive.Show do
  @moduledoc false
  use CodeHorizonWeb, :live_view

  import CodeHorizonWeb.PageComponents

  alias CodeHorizon.Lessons

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:lesson, Lessons.get_lesson!(id))}
  end

  @impl true
  def handle_event("close_modal", _, socket) do
    {:noreply, push_patch(socket, to: ~p"/app/lessons/#{socket.assigns.lesson}")}
  end

  defp page_title(:show), do: "Show Lesson"
  defp page_title(:edit), do: "Edit Lesson"
end
