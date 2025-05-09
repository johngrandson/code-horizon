defmodule CodeHorizon.ProgressTracking.Subscribers.LessonSubscriber do
  @moduledoc """
  Subscribes to lesson domain events and handles their implications
  for student progress tracking.
  """
  use GenServer

  import Ecto.Query

  alias CodeHorizon.EventBus
  alias CodeHorizon.ProgressTracking
  alias CodeHorizon.ProgressTracking.Progress
  alias CodeHorizon.Repo

  require Logger

  # Client API

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  # Server callbacks

  @impl true
  def init(state) do
    # Subscribe to all lesson events
    EventBus.subscribe("lessons")
    Logger.info("ProgressTrackingLessonSubscriber started")
    {:ok, state}
  end

  @impl true
  def handle_info({:deleted, lesson}, state) do
    Logger.info("ProgressTrackingLessonSubscriber received lesson:deleted event")

    # When a lesson is deleted, remove related progress records
    handle_lesson_deletion(lesson.id)

    {:noreply, state}
  end

  @impl true
  def handle_info({:updated, _lesson}, state) do
    Logger.info("ProgressTrackingLessonSubscriber received lesson:updated event")

    # TODO: when lesson content changes significantly, maybe reset progress
    # or mark lessons for review - dependending on business rules

    {:noreply, state}
  end

  @impl true
  def handle_info({event_type, _payload}, state) do
    # Log other events but don't take action
    Logger.debug("ProgressTrackingLessonSubscriber received unhandled event: #{inspect(event_type)}")
    {:noreply, state}
  end

  # Helper functions

  defp handle_lesson_deletion(lesson_id) do
    # Find all progress records for the lesson
    progress_query =
      from p in Progress,
        where: p.lesson_id == ^lesson_id

    # Delete them
    {count, _} = Repo.delete_all(progress_query)

    Logger.info("Deleted #{count} progress records due to lesson deletion")

    # After deleting progress records, we may need to recalculate overall course progress
    # for affected enrollments
    affected_enrollments_query =
      from p in Progress,
        where: p.lesson_id == ^lesson_id,
        select: p.enrollment_id,
        distinct: true

    affected_enrollments = Repo.all(affected_enrollments_query)

    Enum.each(affected_enrollments, fn enrollment_id ->
      ProgressTracking.calculate_enrollment_progress(enrollment_id)
    end)
  end
end
