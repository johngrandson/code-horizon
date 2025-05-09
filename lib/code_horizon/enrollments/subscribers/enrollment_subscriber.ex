defmodule CodeHorizon.ProgressTracking.Subscribers.EnrollmentSubscriber do
  @moduledoc """
  Subscribes to enrollment domain events and handles their implications
  for student progress tracking.
  """
  use GenServer

  alias CodeHorizon.EventBus
  alias CodeHorizon.ProgressTracking

  require Logger

  # Client API

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  # Server callbacks

  @impl true
  def init(state) do
    # Subscribe to all enrollment events
    EventBus.subscribe("enrollments")
    Logger.info("ProgressTrackingEnrollmentSubscriber started")
    {:ok, state}
  end

  @impl true
  def handle_info({:created, enrollment}, state) do
    Logger.info("ProgressTrackingEnrollmentSubscriber received enrollment:created event")

    # When a new enrollment is created, initialize progress tracking for all lessons
    ProgressTracking.initialize_progress_for_enrollment(enrollment.id)

    {:noreply, state}
  end

  @impl true
  def handle_info({:cancelled, _enrollment}, state) do
    Logger.info("ProgressTrackingEnrollmentSubscriber received enrollment:cancelled event")

    # TODO: mark all incomplete lessons as cancelled or take other actions
    # This could be something you want to implement

    {:noreply, state}
  end

  @impl true
  def handle_info({event_type, _payload}, state) do
    # Log other events but don't take action
    Logger.debug("ProgressTrackingEnrollmentSubscriber received unhandled event: #{inspect(event_type)}")
    {:noreply, state}
  end
end
