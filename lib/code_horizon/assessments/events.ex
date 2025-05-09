# lib/code_horizon/assessments/events.ex
defmodule CodeHorizon.Assessments.Events do
  @moduledoc """
  Handles event publication for the Assessments bounded context.
  Encapsulates domain events related to assessments, questions, and attempts.
  """

  alias CodeHorizon.EventBus

  @topic "assessments"
  @attempts_topic "assessment_attempts"

  # Assessment events

  def broadcast_assessment_created(assessment) do
    EventBus.broadcast_entity_event(@topic, :created, assessment, assessment.id)
  end

  def broadcast_assessment_updated(assessment) do
    EventBus.broadcast_entity_event(@topic, :updated, assessment, assessment.id)
  end

  def broadcast_assessment_published(assessment) do
    EventBus.broadcast_entity_event(@topic, :published, assessment, assessment.id)
  end

  def broadcast_assessment_unpublished(assessment) do
    EventBus.broadcast_entity_event(@topic, :unpublished, assessment, assessment.id)
  end

  # Attempt events

  def broadcast_attempt_started(attempt) do
    EventBus.broadcast_entity_event(@attempts_topic, :started, attempt, attempt.id)

    # Also broadcast to student-specific topic
    EventBus.publish(
      "student:#{attempt.student_id}:assessments",
      :attempt_started,
      attempt
    )
  end

  def broadcast_attempt_submitted(attempt) do
    EventBus.broadcast_entity_event(@attempts_topic, :submitted, attempt, attempt.id)
  end

  def broadcast_attempt_graded(attempt) do
    EventBus.broadcast_entity_event(@attempts_topic, :graded, attempt, attempt.id)

    # Also broadcast to student-specific topic
    EventBus.publish(
      "student:#{attempt.student_id}:assessments",
      :attempt_graded,
      attempt
    )
  end

  def broadcast_attempt_passed(attempt) do
    EventBus.broadcast_entity_event(@attempts_topic, :passed, attempt, attempt.id)
  end

  def broadcast_attempt_failed(attempt) do
    EventBus.broadcast_entity_event(@attempts_topic, :failed, attempt, attempt.id)
  end
end
