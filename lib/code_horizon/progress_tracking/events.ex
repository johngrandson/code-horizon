defmodule CodeHorizon.ProgressTracking.Events do
  @moduledoc """
  Handles event publication for the ProgressTracking bounded context.
  Encapsulates domain events related to student progress in lessons.
  """

  alias CodeHorizon.EventBus

  @topic "progress"

  @doc """
  Broadcasts a progress creation event when a student's progress record is initialized.
  """
  def broadcast_created(progress) do
    EventBus.broadcast_entity_event(@topic, :created, progress, progress.id)
  end

  @doc """
  Broadcasts a progress update event when a student's progress is modified.
  """
  def broadcast_updated(progress) do
    EventBus.broadcast_entity_event(@topic, :updated, progress, progress.id)
  end

  @doc """
  Broadcasts a lesson completion event when a student completes a lesson.
  """
  def broadcast_lesson_completed(progress) do
    EventBus.broadcast_entity_event(@topic, :lesson_completed, progress, progress.id)

    # Also broadcast to a student-specific topic
    progress = CodeHorizon.Repo.preload(progress, :enrollment)
    student_id = progress.enrollment.student_id

    EventBus.publish(
      "student:#{student_id}:progress",
      :lesson_completed,
      progress
    )
  end

  @doc """
  Broadcasts a course progress milestone event when a student reaches a significant
  percentage of course completion (e.g., 25%, 50%, 75%).
  """
  def broadcast_milestone_reached(enrollment_id, milestone_percent, course_title) do
    payload = %{
      enrollment_id: enrollment_id,
      milestone_percent: milestone_percent,
      course_title: course_title,
      timestamp: DateTime.utc_now()
    }

    EventBus.publish(@topic, :milestone_reached, payload)
    EventBus.publish("enrollment:#{enrollment_id}:milestones", :reached, payload)
  end
end
