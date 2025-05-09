defmodule CodeHorizon.Enrollments.Subscribers.CourseSubscriber do
  @moduledoc """
  Subscribes to course domain events and handles their implications
  for student enrollments.
  """
  use GenServer

  import Ecto.Query

  alias CodeHorizon.Enrollments.Enrollment
  alias CodeHorizon.EventBus
  alias CodeHorizon.Repo

  require Logger

  # Client API

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  # Server callbacks

  @impl true
  def init(state) do
    # Subscribe to all course events
    EventBus.subscribe("courses")
    Logger.info("EnrollmentCourseSubscriber started and listening for course events")
    {:ok, state}
  end

  @impl true
  def handle_info({:deleted, course}, state) do
    Logger.info("EnrollmentCourseSubscriber received course:deleted event for course #{course.id}")

    # When a course is deleted, cancel all active enrollments
    handle_course_deletion(course.id)

    {:noreply, state}
  end

  @impl true
  def handle_info({:unpublished, course}, state) do
    Logger.info("EnrollmentCourseSubscriber received course:unpublished event for course #{course.id}")

    # When a course is unpublished, notify enrolled students
    notify_students_of_course_unpublication(course.id)

    {:noreply, state}
  end

  @impl true
  def handle_info({event_type, _payload}, state) do
    # Log other events but don't take action
    Logger.debug("EnrollmentCourseSubscriber received unhandled event: #{inspect(event_type)}")
    {:noreply, state}
  end

  # Helper functions

  defp handle_course_deletion(course_id) do
    # Find all active enrollments for the course
    active_enrollments_query =
      from e in Enrollment,
        where: e.course_id == ^course_id and e.status == "active"

    # Update them to cancelled status
    {count, _} =
      Repo.update_all(
        active_enrollments_query,
        set: [status: "cancelled"]
      )

    Logger.info("Cancelled #{count} enrollments due to course deletion")

    # Could also send notifications to affected students
    # could_notify_students(course_id)
  end

  defp notify_students_of_course_unpublication(course_id) do
    # This would typically connect to a notification system
    # For now, we'll just log it
    Logger.info("Course #{course_id} unpublished - student notifications would be sent here")

    # TODO: Implement actual notification logic here, e.g.:
    # enrollments =
    #   from(e in Enrollment, where: e.course_id == ^course_id and e.status == "active")
    #   |> Repo.all()
    #   |> Repo.preload(:student)
    #
    # Enum.each(enrollments, fn enrollment ->
    #   CodeHorizon.Notifications.send_email(
    #     enrollment.student.email,
    #     "Course Unavailable",
    #     "The course you are enrolled in is temporarily unavailable."
    #   )
    # end)
  end
end
