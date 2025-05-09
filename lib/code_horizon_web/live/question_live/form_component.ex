defmodule CodeHorizonWeb.QuestionLive.FormComponent do
  use CodeHorizonWeb, :live_component

  alias CodeHorizon.Assessments

  @impl true
  def update(%{question: question} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
      to_form(Assessments.change_question(question))
     end)}
  end

  @impl true
  def handle_event("validate", %{"question" => question_params}, socket) do
    changeset =
      socket.assigns.question
      |> Assessments.change_question(question_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, form: to_form(changeset))}
  end

  def handle_event("save", %{"question" => question_params}, socket) do
    save_question(socket, socket.assigns.action, question_params)
  end

  defp save_question(socket, :edit, question_params) do
    case Assessments.update_question(socket.assigns.question, question_params) do
      {:ok, _question} ->
        {:noreply,
         socket
         |> put_flash(:info, "Question updated successfully")
         |> push_navigate(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_question(socket, :new, question_params) do
    case Assessments.create_question(question_params) do
      {:ok, _question} ->
        {:noreply,
         socket
         |> put_flash(:info, "Question created successfully")
         |> push_navigate(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
end
