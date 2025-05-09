defmodule CodeHorizonWeb.StudentRoutes do
  @moduledoc """
  Routes specifically for student-facing functionality
  """

  defmacro __using__(_opts) do
    quote do
      live "/student/dashboard", Students.DashboardLive, :index

      live "/student/courses", Students.CourseCatalogLive, :index
      live "/student/courses/:id", Students.CourseDetailsLive, :show

      live "/student/my-learning", Students.MyLearningLive, :index

      live "/student/learning/:course_id", Students.CoursePlayerLive, :index
      live "/student/learning/:course_id/lesson/:lesson_id", Students.CoursePlayerLive, :lesson

      live "/student/assessments", Students.AssessmentsLive, :index
      live "/student/assessments/:id/take", Students.AssessmentPlayerLive, :take
      live "/student/assessments/:id/review", Students.AssessmentPlayerLive, :review

      live "/student/certificates", Students.CertificatesLive, :index
    end
  end
end
