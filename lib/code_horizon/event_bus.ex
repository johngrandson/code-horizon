# lib/code_horizon/event_bus.ex
defmodule CodeHorizon.EventBus do
  @moduledoc """
  Centralized event bus for domain events across bounded contexts.
  Provides a standardized API for publishing and subscribing to events.
  """

  require Logger

  @doc """
  Publishes an event to the specified topic.

  ## Parameters
  - topic: String representing the event category (e.g., "courses")
  - event_type: Atom representing the specific event (e.g., :created, :updated)
  - payload: Map or struct containing the event data

  ## Examples
      EventBus.publish("courses", :created, %{id: "123", title: "Elixir Basics"})
  """
  def publish(topic, event_type, payload) do
    Logger.debug("Publishing event #{event_type} to topic #{topic}")

    Phoenix.PubSub.broadcast(
      CodeHorizon.PubSub,
      topic,
      {event_type, payload}
    )
  end

  @doc """
  Subscribes the current process to a topic.

  ## Parameters
  - topic: String representing the event category to subscribe to

  ## Examples
      EventBus.subscribe("courses")
  """
  def subscribe(topic) do
    Logger.debug("Subscribing to topic #{topic}")

    Phoenix.PubSub.subscribe(CodeHorizon.PubSub, topic)
  end

  @doc """
  Creates a topic string for a specific entity instance.

  ## Examples
      EventBus.entity_topic("courses", "123") # Returns "courses:123"
  """
  def entity_topic(base_topic, entity_id) do
    "#{base_topic}:#{entity_id}"
  end

  @doc """
  Broadcasts an event at both the collection and entity level.

  ## Parameters
  - base_topic: Base topic name (e.g., "courses")
  - event_type: Type of event (:created, :updated, etc.)
  - entity: The entity that is the subject of the event
  - entity_id: ID of the entity

  ## Examples
      EventBus.broadcast_entity_event("courses", :updated, course, course.id)
  """
  def broadcast_entity_event(base_topic, event_type, entity, entity_id) do
    # Broadcast to the collection topic (e.g., "courses")
    publish(base_topic, event_type, entity)

    # Broadcast to the entity-specific topic (e.g., "courses:123")
    publish(entity_topic(base_topic, entity_id), event_type, entity)
  end

  @doc """
  Broadcasts an event only if the operation was successful.
  Commonly used with database operations to ensure events
  are only published when data is successfully persisted.

  ## Parameters
    - result: An {:ok, entity} or {:error, reason} tuple
    - broadcast_fn: Function that takes the entity and broadcasts an event

  ## Examples
      result = Repo.insert(changeset)
      EventBus.broadcast_on_success(result, &Events.broadcast_created/1)
  """
  @spec broadcast_on_success({:ok, struct()} | {:error, term()}, (struct() -> any())) ::
          {:ok, struct()} | {:error, term()}
  def broadcast_on_success({:ok, result} = success, broadcast_fn) when is_function(broadcast_fn, 1) do
    broadcast_fn.(result)
    success
  end

  def broadcast_on_success(error, _broadcast_fn), do: error
end
