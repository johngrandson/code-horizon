defmodule CodeHorizonWeb.AssessmentLive.FormComponent do
  use CodeHorizonWeb, :live_component

  alias CodeHorizon.Assessments

  @impl true
  def update(%{assessment: assessment} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
      to_form(Assessments.change_assessment(assessment))
     end)}
  end

  @impl true
  def handle_event("validate", %{"assessment" => assessment_params}, socket) do
    changeset =
      socket.assigns.assessment
      |> Assessments.change_assessment(assessment_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, form: to_form(changeset))}
  end

  def handle_event("save", %{"assessment" => assessment_params}, socket) do
    save_assessment(socket, socket.assigns.action, assessment_params)
  end

  defp save_assessment(socket, :edit, assessment_params) do
    case Assessments.update_assessment(socket.assigns.assessment, assessment_params) do
      {:ok, _assessment} ->
        {:noreply,
         socket
         |> put_flash(:info, "Assessment updated successfully")
         |> push_navigate(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_assessment(socket, :new, assessment_params) do
    case Assessments.create_assessment(assessment_params) do
      {:ok, _assessment} ->
        {:noreply,
         socket
         |> put_flash(:info, "Assessment created successfully")
         |> push_navigate(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
end
