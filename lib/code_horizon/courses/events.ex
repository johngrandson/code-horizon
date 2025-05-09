defmodule CodeHorizon.Courses.Events do
  @moduledoc """
  Handles event publication for the Courses bounded context.
  Encapsulates domain events related to courses.
  """

  alias CodeHorizon.EventBus

  @topic "courses"

  @doc """
  Broadcasts a course creation event.
  """
  def broadcast_created(course) do
    EventBus.broadcast_entity_event(@topic, :created, course, course.id)
  end

  @doc """
  Broadcasts a course update event.
  """
  def broadcast_updated(course) do
    EventBus.broadcast_entity_event(@topic, :updated, course, course.id)
  end

  @doc """
  Broadcasts a course deletion event.
  """
  def broadcast_deleted(course) do
    EventBus.broadcast_entity_event(@topic, :deleted, course, course.id)
  end

  @doc """
  Broadcasts a course publication event when a course transitions from
  unpublished to published state.
  """
  def broadcast_published(course) do
    EventBus.broadcast_entity_event(@topic, :published, course, course.id)
  end

  @doc """
  Broadcasts a course unpublication event.
  """
  def broadcast_unpublished(course) do
    EventBus.broadcast_entity_event(@topic, :unpublished, course, course.id)
  end
end
