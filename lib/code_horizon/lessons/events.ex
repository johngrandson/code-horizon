defmodule CodeHorizon.Lessons.Events do
  @moduledoc """
  Handles event publication for the Lessons bounded context.
  """

  alias CodeHorizon.EventBus

  @topic "lessons"

  @doc """
  Broadcasts a lesson creation event.
  """
  def broadcast_created(lesson) do
    EventBus.broadcast_entity_event(@topic, :created, lesson, lesson.id)
  end

  @doc """
  Broadcasts a lesson update event.
  """
  def broadcast_updated(lesson) do
    EventBus.broadcast_entity_event(@topic, :updated, lesson, lesson.id)
  end

  @doc """
  Broadcasts a lesson deletion event.
  """
  def broadcast_deleted(lesson) do
    EventBus.broadcast_entity_event(@topic, :deleted, lesson, lesson.id)
  end

  @doc """
  Broadcasts a lesson completion event when a student completes a lesson.
  """
  def broadcast_completed(lesson, student_id) do
    # For events with additional context beyond the entity itself,
    # we can include that in the payload
    enriched_payload = Map.put(lesson, :completed_by, student_id)

    # Broadcast to lessons topic
    EventBus.publish(@topic, :completed, enriched_payload)

    # Broadcast to specific lesson topic
    EventBus.publish(
      EventBus.entity_topic(@topic, lesson.id),
      :completed,
      enriched_payload
    )

    # Also broadcast to a topic specific to the student's progress
    EventBus.publish(
      "student_progress:#{student_id}",
      :lesson_completed,
      enriched_payload
    )
  end
end
