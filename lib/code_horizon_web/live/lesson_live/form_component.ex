defmodule CodeHorizonWeb.LessonLive.FormComponent do
  use CodeHorizonWeb, :live_component

  alias CodeHorizon.Lessons

  @impl true
  def update(%{lesson: lesson} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
      to_form(Lessons.change_lesson(lesson))
     end)}
  end

  @impl true
  def handle_event("validate", %{"lesson" => lesson_params}, socket) do
    changeset =
      socket.assigns.lesson
      |> Lessons.change_lesson(lesson_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, form: to_form(changeset))}
  end

  def handle_event("save", %{"lesson" => lesson_params}, socket) do
    save_lesson(socket, socket.assigns.action, lesson_params)
  end

  defp save_lesson(socket, :edit, lesson_params) do
    case Lessons.update_lesson(socket.assigns.lesson, lesson_params) do
      {:ok, _lesson} ->
        {:noreply,
         socket
         |> put_flash(:info, "Lesson updated successfully")
         |> push_navigate(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_lesson(socket, :new, lesson_params) do
    case Lessons.create_lesson(lesson_params) do
      {:ok, _lesson} ->
        {:noreply,
         socket
         |> put_flash(:info, "Lesson created successfully")
         |> push_navigate(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
end
