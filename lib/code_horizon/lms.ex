# lib/code_horizon/lms.ex
defmodule CodeHorizon.LMS do
  @moduledoc """
  A high-level facade for the Learning Management System.

  This module provides a simplified API for common LMS operations that span
  multiple bounded contexts. It orchestrates interactions between the various
  sub-systems (Courses, Lessons, Enrollments, ProgressTracking, Assessments)
  without exposing their implementation details.

  Use this module when you need to perform complex operations that involve
  multiple bounded contexts in a consistent and atomic way.
  """

  import Ecto.Query

  alias CodeHorizon.Assessments
  alias CodeHorizon.Courses
  alias CodeHorizon.Enrollments
  alias CodeHorizon.ProgressTracking
  alias CodeHorizon.Repo
  alias CodeHorizon.Students.StudentDashboard

  def get_student_dashboard_data(student_id) do
    %StudentDashboard{
      id: student_id,
      enrolled_courses: Enrollments.list_enrollments_by_student_id(student_id),
      upcoming_assessments: Assessments.list_assessments_by_student_id(student_id),
      recent_activity: ProgressTracking.get_recent_activity(student_id),
      recommended_courses: Courses.list_recommended_courses_by_student_id(student_id)
    }
  end

  @doc """
  Enrolls a student in a course, setting up all necessary records.

  This operation:
  1. Creates an enrollment record
  2. Initializes progress tracking for all lessons
  3. Grants access to course materials

  ## Parameters
    - student_id: The UUID of the student to enroll
    - course_id: The UUID of the course to enroll in

  ## Returns
    - {:ok, %{enrollment: enrollment, progress_records: [progress]}} - On success
    - {:error, failed_operation, failed_value, changes_so_far} - On failure
  """
  def enroll_student(student_id, course_id) do
    Ecto.Multi.new()
    |> Ecto.Multi.run(:course, fn _repo, _changes ->
      case Courses.get_course!(course_id) do
        nil -> {:error, :course_not_found}
        course -> {:ok, course}
      end
    end)
    |> Ecto.Multi.run(:enrollment, fn _repo, %{course: _course} ->
      Enrollments.create_enrollment(%{
        student_id: student_id,
        course_id: course_id,
        status: "active",
        enrolled_at: DateTime.utc_now()
      })
    end)
    |> Ecto.Multi.run(:progress_init, fn _repo, %{enrollment: enrollment} ->
      # Initialize progress tracking
      progress_records = ProgressTracking.initialize_progress_for_enrollment(enrollment.id)
      {:ok, progress_records}
    end)
    |> Repo.transaction()
  end

  @doc """
  Completes a lesson for a student and updates all related records.

  This operation:
  1. Marks the lesson as completed
  2. Updates the overall course progress
  3. Checks if the course is now completed

  ## Parameters
    - student_id: The UUID of the student
    - course_id: The UUID of the course
    - lesson_id: The UUID of the lesson being completed

  ## Returns
    - {:ok, %{progress: progress, overall_percent: percent}} - On success
    - {:error, reason} - On failure
  """
  def complete_lesson(student_id, course_id, lesson_id) do
    with {:ok, enrollment} <- get_enrollment(student_id, course_id),
         {:ok, progress} <- ProgressTracking.complete_lesson(enrollment.id, lesson_id) do
      # Calcular progresso geral do curso
      overall_percent = ProgressTracking.calculate_enrollment_progress(enrollment.id)

      # Verificar se o curso foi concluído
      if overall_percent == 100 do
        Enrollments.complete_enrollment(enrollment)
      end

      {:ok, %{progress: progress, overall_percent: overall_percent}}
    end
  end

  @doc """
  Takes an assessment and submits answers.

  This operation:
  1. Starts or retrieves an existing assessment attempt
  2. Records student answers
  3. Submits and grades the attempt (for auto-gradable assessments)
  4. Updates course progress if applicable

  ## Parameters
    - student_id: The UUID of the student
    - assessment_id: The UUID of the assessment
    - answers: A list of answer maps with question_id and answer data

  ## Returns
    - {:ok, %{attempt: attempt, score: score}} - On success
    - {:error, reason} - On failure
  """
  def take_assessment(student_id, assessment_id, answers) do
    Ecto.Multi.new()
    |> Ecto.Multi.run(:assessment, fn _repo, _changes ->
      case Assessments.get_assessment!(assessment_id) do
        nil -> {:error, :assessment_not_found}
        assessment -> {:ok, assessment}
      end
    end)
    |> Ecto.Multi.run(:enrollment, fn _repo, %{assessment: assessment} ->
      get_enrollment(student_id, assessment.course_id)
    end)
    |> Ecto.Multi.run(:attempt, fn _repo, %{enrollment: enrollment, assessment: assessment} ->
      Assessments.start_assessment_attempt(assessment.id, student_id, enrollment.id)
    end)
    |> Ecto.Multi.run(:answers, fn _repo, %{attempt: attempt} ->
      record_answers(attempt.id, answers)
    end)
    |> Ecto.Multi.run(:submission, fn _repo, %{attempt: attempt} ->
      Assessments.submit_assessment_attempt(attempt)
    end)
    |> Repo.transaction()
  end

  @doc """
  Generates a course completion certificate.

  This operation:
  1. Verifies course completion eligibility
  2. Creates a certificate record
  3. Generates the certificate document

  ## Parameters
    - student_id: The UUID of the student
    - course_id: The UUID of the course

  ## Returns
    - {:ok, certificate} - On success
    - {:error, reason} - On failure
  """
  def generate_course_certificate(student_id, course_id) do
    with {:ok, enrollment} <- get_enrollment(student_id, course_id),
         :ok <- verify_course_completion(enrollment) do
      create_certificate(enrollment)
    end
  end

  @doc """
  Gets analytics data for a course, including enrollment and completion statistics.

  ## Parameters
    - course_id: The UUID of the course

  ## Returns
    - {:ok, analytics_data} - On success
    - {:error, reason} - On failure
  """
  def get_course_analytics(course_id) do
    course = Courses.get_course!(course_id)

    if course do
      # Total of enrollments
      enrollment_count_query =
        from e in "enrollments",
          where: e.course_id == ^course_id,
          select: count(e.id)

      # Total of completed enrollments
      completion_count_query =
        from e in "enrollments",
          where: e.course_id == ^course_id and e.status == "completed",
          select: count(e.id)

      # Average progress
      avg_progress_query =
        from p in "progress_tracking_progress",
          join: e in "enrollments",
          on: p.enrollment_id == e.id,
          where: e.course_id == ^course_id,
          select: avg(p.percent_complete)

      # Execute queries
      enrollment_count = Repo.one(enrollment_count_query) || 0
      completion_count = Repo.one(completion_count_query) || 0
      avg_progress = Repo.one(avg_progress_query) || 0

      completion_rate =
        if enrollment_count > 0 do
          completion_count / enrollment_count * 100
        else
          0
        end

      analytics = %{
        course: course,
        enrollment_count: enrollment_count,
        completion_count: completion_count,
        completion_rate: completion_rate,
        avg_progress: avg_progress
      }

      {:ok, analytics}
    else
      {:error, :course_not_found}
    end
  end

  # Helper functions

  defp get_enrollment(student_id, course_id) do
    case Enrollments.get_enrollment_by_student_and_course(student_id, course_id) do
      nil -> {:error, :enrollment_not_found}
      enrollment -> {:ok, enrollment}
    end
  end

  defp verify_course_completion(enrollment) do
    if enrollment.status == "completed" do
      :ok
    else
      {:error, :course_not_completed}
    end
  end

  defp create_certificate(enrollment) do
    # TODO: Example implementation of creating a certificate
    # Certificates.create_certificate(%{
    #   enrollment_id: enrollment.id,
    #   issue_date: DateTime.utc_now(),
    #   verification_code: generate_verification_code()
    # })

    # Generate a random verification code for the certificate
    certificate = %{
      id: Ecto.UUID.generate(),
      enrollment_id: enrollment.id,
      course_id: enrollment.course_id,
      student_id: enrollment.student_id,
      issue_date: DateTime.utc_now(),
      verification_code: "CERT-#{:rand.uniform(999_999)}"
    }

    {:ok, certificate}
  end

  defp record_answers(attempt_id, answers) do
    results =
      Enum.map(answers, fn answer_params ->
        # Add attempt_id
        params = Map.put(answer_params, :attempt_id, attempt_id)
        Assessments.create_attempt_answer(params)
      end)

    # Verifies if there are any errors
    if Enum.any?(results, fn {status, _} -> status == :error end) do
      # Return the first error
      Enum.find(results, fn {status, _} -> status == :error end)
    else
      # Return all answers with success
      {:ok, Enum.map(results, fn {:ok, answer} -> answer end)}
    end
  end
end
