defmodule CodeHorizon.Assessments.Subscribers.CourseSubscriber do
  @moduledoc """
  Subscribes to course domain events and handles their implications
  for assessments.
  """
  use GenServer

  import Ecto.Query

  alias CodeHorizon.Assessments
  alias CodeHorizon.Assessments.Assessment
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
    Logger.info("AssessmentsCourseSubscriber started and listening for course events")
    {:ok, state}
  end

  @impl true
  def handle_info({:deleted, course}, state) do
    Logger.info("AssessmentsCourseSubscriber received course:deleted event for course #{course.id}")

    # When a course is deleted, handle its assessments
    handle_course_deletion(course.id)

    {:noreply, state}
  end

  @impl true
  def handle_info({:unpublished, course}, state) do
    Logger.info("AssessmentsCourseSubscriber received course:unpublished event for course #{course.id}")

    # When a course is unpublished, we might want to unpublish its assessments
    unpublish_course_assessments(course.id)

    {:noreply, state}
  end

  @impl true
  def handle_info({event_type, _payload}, state) do
    # Log other events but don't take action
    Logger.debug("AssessmentsCourseSubscriber received unhandled event: #{inspect(event_type)}")
    {:noreply, state}
  end

  # Helper functions

  defp handle_course_deletion(course_id) do
    # Option: Mark assessments as archived/deleted
    # Or actually delete them if that's the business rule
    assessments_query =
      from a in Assessment,
        where: a.course_id == ^course_id

    {count, _} = Repo.update_all(assessments_query, set: [is_published: false])

    Logger.info("Unpublished #{count} assessments due to course deletion")
  end

  defp unpublish_course_assessments(course_id) do
    assessments_query =
      from a in Assessment,
        where: a.course_id == ^course_id and a.is_published == true

    {count, _} = Repo.update_all(assessments_query, set: [is_published: false])

    Logger.info("Unpublished #{count} assessments due to course unpublication")

    # Additionally, we might want to fetch each assessment and broadcast events
    if count > 0 do
      assessments =
        Repo.all(from(a in Assessment, where: a.course_id == ^course_id))

      Enum.each(assessments, fn assessment ->
        Assessments.Events.broadcast_assessment_unpublished(assessment)
      end)
    end
  end
end
