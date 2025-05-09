defmodule CodeHorizonWeb.EnrollmentLive.FormComponent do
  use CodeHorizonWeb, :live_component

  alias CodeHorizon.Enrollments

  @impl true
  def update(%{enrollment: enrollment} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
      to_form(Enrollments.change_enrollment(enrollment))
     end)}
  end

  @impl true
  def handle_event("validate", %{"enrollment" => enrollment_params}, socket) do
    changeset =
      socket.assigns.enrollment
      |> Enrollments.change_enrollment(enrollment_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, form: to_form(changeset))}
  end

  def handle_event("save", %{"enrollment" => enrollment_params}, socket) do
    save_enrollment(socket, socket.assigns.action, enrollment_params)
  end

  defp save_enrollment(socket, :edit, enrollment_params) do
    case Enrollments.update_enrollment(socket.assigns.enrollment, enrollment_params) do
      {:ok, _enrollment} ->
        {:noreply,
         socket
         |> put_flash(:info, "Enrollment updated successfully")
         |> push_navigate(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_enrollment(socket, :new, enrollment_params) do
    case Enrollments.create_enrollment(enrollment_params) do
      {:ok, _enrollment} ->
        {:noreply,
         socket
         |> put_flash(:info, "Enrollment created successfully")
         |> push_navigate(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
end
