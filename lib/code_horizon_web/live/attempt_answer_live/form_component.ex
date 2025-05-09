defmodule CodeHorizonWeb.AttemptAnswerLive.FormComponent do
  use CodeHorizonWeb, :live_component

  alias CodeHorizon.Assessments

  @impl true
  def update(%{attempt_answer: attempt_answer} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
      to_form(Assessments.change_attempt_answer(attempt_answer))
     end)}
  end

  @impl true
  def handle_event("validate", %{"attempt_answer" => attempt_answer_params}, socket) do
    changeset =
      socket.assigns.attempt_answer
      |> Assessments.change_attempt_answer(attempt_answer_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, form: to_form(changeset))}
  end

  def handle_event("save", %{"attempt_answer" => attempt_answer_params}, socket) do
    save_attempt_answer(socket, socket.assigns.action, attempt_answer_params)
  end

  defp save_attempt_answer(socket, :edit, attempt_answer_params) do
    case Assessments.update_attempt_answer(socket.assigns.attempt_answer, attempt_answer_params) do
      {:ok, _attempt_answer} ->
        {:noreply,
         socket
         |> put_flash(:info, "Attempt answer updated successfully")
         |> push_navigate(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_attempt_answer(socket, :new, attempt_answer_params) do
    case Assessments.create_attempt_answer(attempt_answer_params) do
      {:ok, _attempt_answer} ->
        {:noreply,
         socket
         |> put_flash(:info, "Attempt answer created successfully")
         |> push_navigate(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
end
