defmodule CodeHorizonWeb.LMSRoutes do
  @moduledoc """
  Routes related to the Learning Management System domain.
  Includes courses, lessons, enrollments, progress tracking, and assessments.
  """

  defmacro __using__(_opts) do
    quote do
      live "/courses", CourseLive.Index, :index
      live "/courses/new", CourseLive.Index, :new
      live "/courses/:id/edit", CourseLive.Index, :edit
      live "/courses/:id", CourseLive.Show, :show
      live "/courses/:id/show/edit", CourseLive.Show, :edit

      live "/lessons", LessonLive.Index, :index
      live "/lessons/new", LessonLive.Index, :new
      live "/lessons/:id/edit", LessonLive.Index, :edit
      live "/lessons/:id", LessonLive.Show, :show
      live "/lessons/:id/show/edit", LessonLive.Show, :edit

      live "/enrollments", EnrollmentLive.Index, :index
      live "/enrollments/new", EnrollmentLive.Index, :new
      live "/enrollments/:id/edit", EnrollmentLive.Index, :edit
      live "/enrollments/:id", EnrollmentLive.Show, :show
      live "/enrollments/:id/show/edit", EnrollmentLive.Show, :edit

      live "/progress", ProgressLive.Index, :index
      live "/progress/new", ProgressLive.Index, :new
      live "/progress/:id/edit", ProgressLive.Index, :edit
      live "/progress/:id", ProgressLive.Show, :show
      live "/progress/:id/show/edit", ProgressLive.Show, :edit

      live "/assessments", AssessmentLive.Index, :index
      live "/assessments/new", AssessmentLive.Index, :new
      live "/assessments/:id/edit", AssessmentLive.Index, :edit
      live "/assessments/:id", AssessmentLive.Show, :show
      live "/assessments/:id/show/edit", AssessmentLive.Show, :edit

      live "/questions", QuestionLive.Index, :index
      live "/questions/new", QuestionLive.Index, :new
      live "/questions/:id/edit", QuestionLive.Index, :edit
      live "/questions/:id", QuestionLive.Show, :show
      live "/questions/:id/show/edit", QuestionLive.Show, :edit

      live "/question_options", QuestionOptionLive.Index, :index
      live "/question_options/new", QuestionOptionLive.Index, :new
      live "/question_options/:id/edit", QuestionOptionLive.Index, :edit
      live "/question_options/:id", QuestionOptionLive.Show, :show
      live "/question_options/:id/show/edit", QuestionOptionLive.Show, :edit

      live "/assessment_attempts", AssessmentAttemptLive.Index, :index
      live "/assessment_attempts/new", AssessmentAttemptLive.Index, :new
      live "/assessment_attempts/:id/edit", AssessmentAttemptLive.Index, :edit
      live "/assessment_attempts/:id", AssessmentAttemptLive.Show, :show
      live "/assessment_attempts/:id/show/edit", AssessmentAttemptLive.Show, :edit

      live "/attempt_answers", AttemptAnswerLive.Index, :index
      live "/attempt_answers/new", AttemptAnswerLive.Index, :new
      live "/attempt_answers/:id/edit", AttemptAnswerLive.Index, :edit
      live "/attempt_answers/:id", AttemptAnswerLive.Show, :show
      live "/attempt_answers/:id/show/edit", AttemptAnswerLive.Show, :edit
    end
  end
end
