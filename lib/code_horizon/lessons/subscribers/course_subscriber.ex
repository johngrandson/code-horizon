defmodule CodeHorizon.Lessons.Subscribers.CourseSubscriber do
  @moduledoc """
  Subscribes to course domain events and reacts appropriately
  within the Lessons bounded context.
  """
  use GenServer

  alias CodeHorizon.EventBus
  alias CodeHorizon.Lessons

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
    Logger.info("CourseSubscriber started and listening for course events")
    {:ok, state}
  end

  @impl true
  def handle_info({:deleted, course}, state) do
    Logger.info("CourseSubscriber received course:deleted event for course #{course.id}")

    # When a course is deleted, archive or handle its lessons
    Lessons.handle_course_deletion(course.id)

    {:noreply, state}
  end

  @impl true
  def handle_info({:published, course}, state) do
    Logger.info("CourseSubscriber received course:published event for course #{course.id}")

    # When a course is published, validate its lessons
    Lessons.validate_lessons_for_published_course(course.id)

    {:noreply, state}
  end

  @impl true
  def handle_info({event_type, _payload}, state) do
    # Log other events but don't take action
    Logger.debug("CourseSubscriber received unhandled event: #{inspect(event_type)}")
    {:noreply, state}
  end
end
