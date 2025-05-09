defmodule CodeHorizonWeb.AssessmentAttemptLive.FormComponent do
  use CodeHorizonWeb, :live_component

  alias CodeHorizon.Assessments

  @impl true
  def update(%{assessment_attempt: assessment_attempt} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
      to_form(Assessments.change_assessment_attempt(assessment_attempt))
     end)}
  end

  @impl true
  def handle_event("validate", %{"assessment_attempt" => assessment_attempt_params}, socket) do
    changeset =
      socket.assigns.assessment_attempt
      |> Assessments.change_assessment_attempt(assessment_attempt_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, form: to_form(changeset))}
  end

  def handle_event("save", %{"assessment_attempt" => assessment_attempt_params}, socket) do
    save_assessment_attempt(socket, socket.assigns.action, assessment_attempt_params)
  end

  defp save_assessment_attempt(socket, :edit, assessment_attempt_params) do
    case Assessments.update_assessment_attempt(socket.assigns.assessment_attempt, assessment_attempt_params) do
      {:ok, _assessment_attempt} ->
        {:noreply,
         socket
         |> put_flash(:info, "Assessment attempt updated successfully")
         |> push_navigate(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_assessment_attempt(socket, :new, assessment_attempt_params) do
    case Assessments.create_assessment_attempt(assessment_attempt_params) do
      {:ok, _assessment_attempt} ->
        {:noreply,
         socket
         |> put_flash(:info, "Assessment attempt created successfully")
         |> push_navigate(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
end
