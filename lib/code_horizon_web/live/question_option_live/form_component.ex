defmodule CodeHorizonWeb.QuestionOptionLive.FormComponent do
  use CodeHorizonWeb, :live_component

  alias CodeHorizon.Assessments

  @impl true
  def update(%{question_option: question_option} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
      to_form(Assessments.change_question_option(question_option))
     end)}
  end

  @impl true
  def handle_event("validate", %{"question_option" => question_option_params}, socket) do
    changeset =
      socket.assigns.question_option
      |> Assessments.change_question_option(question_option_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, form: to_form(changeset))}
  end

  def handle_event("save", %{"question_option" => question_option_params}, socket) do
    save_question_option(socket, socket.assigns.action, question_option_params)
  end

  defp save_question_option(socket, :edit, question_option_params) do
    case Assessments.update_question_option(socket.assigns.question_option, question_option_params) do
      {:ok, _question_option} ->
        {:noreply,
         socket
         |> put_flash(:info, "Question option updated successfully")
         |> push_navigate(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_question_option(socket, :new, question_option_params) do
    case Assessments.create_question_option(question_option_params) do
      {:ok, _question_option} ->
        {:noreply,
         socket
         |> put_flash(:info, "Question option created successfully")
         |> push_navigate(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
end
