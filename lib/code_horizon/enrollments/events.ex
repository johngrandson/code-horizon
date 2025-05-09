defmodule CodeHorizon.Enrollments.Events do
  @moduledoc """
  Handles domain events related to student enrollments.

  This module defines domain-specific events that occur during the enrollment lifecycle
  and publishes them to the system's event bus. It implements the Event Notification pattern
  from DDD, allowing other bounded contexts to react to significant state changes.
  """

  alias CodeHorizon.Enrollments.Enrollment
  alias CodeHorizon.EventBus

  @topic "enrollments"

  @doc """
  Student has been enrolled in a course.
  Signals the creation of a new enrollment relationship between student and course.

  ## Example
      iex> student_enrolled(%Enrollment{student_id: "123", course_id: "456"})
  """
  def student_enrolled(%Enrollment{} = enrollment) do
    # Use both the semantic domain event and the CRUD-style event for compatibility
    EventBus.publish(@topic, :student_enrolled, enrollment)
    EventBus.broadcast_entity_event(@topic, :created, enrollment, enrollment.id)
  end

  @doc """
  Student has completed all course requirements.
  This marks a significant achievement in the student's learning journey.

  ## Example
      iex> course_completed(%Enrollment{student_id: "123", course_id: "456", status: "completed"})
  """
  def course_completed(%Enrollment{} = enrollment) do
    EventBus.publish(@topic, :course_completed, enrollment)
    EventBus.broadcast_entity_event(@topic, :completed, enrollment, enrollment.id)
  end

  @doc """
  Student has cancelled their enrollment before completion.
  This might trigger business processes like refund workflows.

  ## Example
      iex> enrollment_cancelled(%Enrollment{student_id: "123", course_id: "456", status: "cancelled"})
  """
  def enrollment_cancelled(%Enrollment{} = enrollment) do
    EventBus.publish(@topic, :enrollment_cancelled, enrollment)
    EventBus.broadcast_entity_event(@topic, :cancelled, enrollment, enrollment.id)
  end

  @doc """
  Enrollment has expired, typically due to time-limited course access.

  ## Example
      iex> enrollment_expired(%Enrollment{student_id: "123", course_id: "456", status: "expired"})
  """
  def enrollment_expired(%Enrollment{} = enrollment) do
    EventBus.publish(@topic, :enrollment_expired, enrollment)
    EventBus.broadcast_entity_event(@topic, :expired, enrollment, enrollment.id)
  end

  @doc """
  Enrollment has been updated with non-state-changing modifications.
  For general updates that don't fall into other domain events.

  ## Example
      iex> enrollment_details_updated(%Enrollment{student_id: "123", course_id: "456"})
  """
  def enrollment_details_updated(%Enrollment{} = enrollment) do
    EventBus.publish(@topic, :enrollment_details_updated, enrollment)
    EventBus.broadcast_entity_event(@topic, :updated, enrollment, enrollment.id)
  end
end
