defmodule CodeHorizon.Assessments do
  @moduledoc """
  The Assessments context.
  """

  import Ecto.Query, warn: false

  alias CodeHorizon.Assessments.Assessment
  alias CodeHorizon.Assessments.AssessmentAttempt
  alias CodeHorizon.Assessments.AttemptAnswer
  alias CodeHorizon.Assessments.Events
  alias CodeHorizon.Assessments.Question
  alias CodeHorizon.Assessments.QuestionOption
  alias CodeHorizon.Enrollments.Enrollment
  alias CodeHorizon.EventBus
  alias CodeHorizon.Repo

  # CRUD operations for Assessment

  def list_assessments do
    Repo.all(Assessment)
  end

  def get_assessment!(id), do: Repo.get!(Assessment, id)

  def create_assessment(attrs \\ %{}) do
    %Assessment{}
    |> Assessment.changeset(attrs)
    |> Repo.insert()
    |> EventBus.broadcast_on_success(&Events.broadcast_assessment_created/1)
  end

  def update_assessment(%Assessment{} = assessment, attrs) do
    assessment
    |> Assessment.changeset(attrs)
    |> Repo.update()
    |> EventBus.broadcast_on_success(&Events.broadcast_assessment_updated/1)
  end

  def delete_assessment(%Assessment{} = assessment) do
    Repo.delete(assessment)
  end

  def change_assessment(%Assessment{} = assessment, attrs \\ %{}) do
    Assessment.changeset(assessment, attrs)
  end

  # Assessment publishing operations

  def publish_assessment(%Assessment{} = assessment) do
    assessment
    |> update_assessment(%{is_published: true})
    |> EventBus.broadcast_on_success(&Events.broadcast_assessment_published/1)
  end

  def unpublish_assessment(%Assessment{} = assessment) do
    assessment
    |> update_assessment(%{is_published: false})
    |> EventBus.broadcast_on_success(&Events.broadcast_assessment_unpublished/1)
  end

  @doc """
  Lists upcoming assessments for a student.

  This function retrieves assessments that the student needs to complete,
  ordered by due date (if available). It only includes assessments from
  courses where the student has an active enrollment and excludes
  assessments that have already been completed.

  ## Parameters

    * `student_id` - The ID of the student

  ## Returns

  A list of assessment maps with relevant information for display.
  """
  def list_upcoming_assessments_for_student(student_id) do
    # Get course IDs where student is actively enrolled
    enrolled_course_ids = get_active_enrollment_course_ids(student_id)

    # Return empty list if student has no active enrollments
    if Enum.empty?(enrolled_course_ids) do
      []
    else
      fetch_upcoming_assessments(student_id, enrolled_course_ids)
    end
  end

  def list_assessments_by_student_id(student_id) do
    Repo.all(from a in Assessment, where: a.student_id == ^student_id)
  end

  # Gets IDs of courses where the student has an active enrollment.
  defp get_active_enrollment_course_ids(student_id) do
    Enrollment
    |> where([e], e.student_id == ^student_id and e.status == :active)
    |> select([e], e.course_id)
    |> Repo.all()
  end

  # Fetches upcoming assessments for a student from the specified courses.
  defp fetch_upcoming_assessments(student_id, course_ids) do
    Repo.all(
      from(a in Assessment,
        where: a.course_id in ^course_ids and a.is_published == true,
        join: c in assoc(a, :course),
        left_join: att in AssessmentAttempt,
        on: att.assessment_id == a.id and att.student_id == ^student_id,
        where: is_nil(att.id) or att.status not in [:submitted, :graded, :passed],
        order_by: [asc: a.inserted_at, asc: a.id],
        limit: 5,
        select: %{
          id: a.id,
          title: a.title,
          course_id: a.course_id,
          course_title: c.title,
          assessment_type: a.assessment_type,
          time_limit_minutes: a.time_limit_minutes
        }
      )
    )
  end

  # Assessment attempt functions

  def start_assessment_attempt(assessment_id, student_id, enrollment_id) do
    case get_in_progress_attempt(assessment_id, student_id) do
      nil ->
        attrs = %{
          assessment_id: assessment_id,
          student_id: student_id,
          enrollment_id: enrollment_id,
          status: "in_progress",
          start_time: DateTime.utc_now(),
          score: 0
        }

        {:ok, attempt} = create_assessment_attempt(attrs)
        Events.broadcast_attempt_started(attempt)
        {:ok, attempt}

      attempt ->
        {:ok, attempt}
    end
  end

  def submit_assessment_attempt(%AssessmentAttempt{} = attempt) do
    attrs = %{
      status: "submitted",
      end_time: DateTime.utc_now()
    }

    attempt
    |> AssessmentAttempt.changeset(attrs)
    |> Repo.update()
    |> EventBus.broadcast_on_success(&Events.broadcast_attempt_submitted/1)
    |> handle_auto_grading()
  end

  # Helper for cleaner auto-grading flow
  defp handle_auto_grading({:ok, updated_attempt} = success) do
    case get_assessment!(updated_attempt.assessment_id) do
      %{assessment_type: type} when type in ["quiz", "true_false"] ->
        grade_assessment_attempt(updated_attempt)

      _ ->
        success
    end
  end

  defp handle_auto_grading(error), do: error

  def grade_assessment_attempt(%AssessmentAttempt{} = attempt) do
    assessment = get_assessment!(attempt.assessment_id)
    answers = list_attempt_answers_by_attempt(attempt.id)

    # Calculate scores
    total_points = calculate_total_points(assessment.id)
    scored_points = calculate_scored_points(answers)
    percentage_score = calculate_percentage_score(scored_points, total_points)

    # Determine pass/fail status
    status = if percentage_score >= assessment.passing_score, do: "passed", else: "failed"

    # Update attempt with final score
    {:ok, graded_attempt} =
      update_assessment_attempt(attempt, %{
        status: status,
        score: percentage_score
      })

    # Broadcast appropriate events
    broadcast_grading_events(graded_attempt, status)

    {:ok, graded_attempt}
  end

  # Helper functions for cleaner code
  defp calculate_percentage_score(scored_points, total_points) do
    if total_points > 0, do: floor(scored_points / total_points * 100), else: 0
  end

  defp broadcast_grading_events(attempt, status) do
    Events.broadcast_attempt_graded(attempt)

    case status do
      "passed" -> Events.broadcast_attempt_passed(attempt)
      "failed" -> Events.broadcast_attempt_failed(attempt)
    end
  end

  def get_in_progress_attempt(assessment_id, student_id) do
    Repo.get_by(AssessmentAttempt,
      assessment_id: assessment_id,
      student_id: student_id,
      status: "in_progress"
    )
  end

  def calculate_total_points(assessment_id) do
    Repo.one(
      from q in Question,
        where: q.assessment_id == ^assessment_id,
        select: sum(q.points)
    ) || 0
  end

  def calculate_scored_points(answers) do
    Enum.reduce(answers, 0, fn answer, acc ->
      acc + (answer.points_awarded || 0)
    end)
  end

  # CRUD operations for Question

  def list_questions do
    Repo.all(Question)
  end

  def get_question!(id), do: Repo.get!(Question, id)

  def create_question(attrs \\ %{}) do
    %Question{}
    |> Question.changeset(attrs)
    |> Repo.insert()
  end

  def update_question(%Question{} = question, attrs) do
    question
    |> Question.changeset(attrs)
    |> Repo.update()
  end

  def delete_question(%Question{} = question) do
    Repo.delete(question)
  end

  def change_question(%Question{} = question, attrs \\ %{}) do
    Question.changeset(question, attrs)
  end

  # CRUD operations for QuestionOption

  def list_question_options do
    Repo.all(QuestionOption)
  end

  def get_question_option!(id), do: Repo.get!(QuestionOption, id)

  def create_question_option(attrs \\ %{}) do
    %QuestionOption{}
    |> QuestionOption.changeset(attrs)
    |> Repo.insert()
  end

  def update_question_option(%QuestionOption{} = question_option, attrs) do
    question_option
    |> QuestionOption.changeset(attrs)
    |> Repo.update()
  end

  def delete_question_option(%QuestionOption{} = question_option) do
    Repo.delete(question_option)
  end

  def change_question_option(%QuestionOption{} = question_option, attrs \\ %{}) do
    QuestionOption.changeset(question_option, attrs)
  end

  # CRUD operations for AssessmentAttempt

  def list_assessment_attempts do
    Repo.all(AssessmentAttempt)
  end

  def get_assessment_attempt!(id), do: Repo.get!(AssessmentAttempt, id)

  def create_assessment_attempt(attrs \\ %{}) do
    %AssessmentAttempt{}
    |> AssessmentAttempt.changeset(attrs)
    |> Repo.insert()
  end

  def update_assessment_attempt(%AssessmentAttempt{} = assessment_attempt, attrs) do
    assessment_attempt
    |> AssessmentAttempt.changeset(attrs)
    |> Repo.update()
  end

  def delete_assessment_attempt(%AssessmentAttempt{} = assessment_attempt) do
    Repo.delete(assessment_attempt)
  end

  def change_assessment_attempt(%AssessmentAttempt{} = assessment_attempt, attrs \\ %{}) do
    AssessmentAttempt.changeset(assessment_attempt, attrs)
  end

  # CRUD operations for AttemptAnswer

  def list_attempt_answers do
    Repo.all(AttemptAnswer)
  end

  def list_attempt_answers_by_attempt(attempt_id) do
    AttemptAnswer
    |> where(attempt_id: ^attempt_id)
    |> order_by([a], a.question_id)
    |> preload([:question, :selected_option])
    |> Repo.all()
  end

  def get_attempt_answer!(id), do: Repo.get!(AttemptAnswer, id)

  def create_attempt_answer(attrs \\ %{}) do
    %AttemptAnswer{}
    |> AttemptAnswer.changeset(attrs)
    |> Repo.insert()
  end

  def update_attempt_answer(%AttemptAnswer{} = attempt_answer, attrs) do
    attempt_answer
    |> AttemptAnswer.changeset(attrs)
    |> Repo.update()
  end

  def delete_attempt_answer(%AttemptAnswer{} = attempt_answer) do
    Repo.delete(attempt_answer)
  end

  def change_attempt_answer(%AttemptAnswer{} = attempt_answer, attrs \\ %{}) do
    AttemptAnswer.changeset(attempt_answer, attrs)
  end
end
