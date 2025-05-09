defmodule CodeHorizonWeb.InstructorRoutes do
  @moduledoc """
  Routes specifically for instructor-facing functionality
  """

  defmacro __using__(_opts) do
    quote do
      live "/instructor/dashboard", Instructors.DashboardLive, :index

      live "/instructor/courses", Instructors.CoursesLive, :index
      live "/instructor/courses/new", Instructors.CoursesLive, :new
      live "/instructor/courses/:id/edit", Instructors.CoursesLive, :edit
      live "/instructor/courses/:id", Instructors.CourseDetailsLive, :show

      live "/instructor/courses/:course_id/lessons", Instructors.LessonsLive, :index
      live "/instructor/courses/:course_id/lessons/new", Instructors.LessonsLive, :new
      live "/instructor/courses/:course_id/lessons/:id/edit", Instructors.LessonsLive, :edit

      live "/instructor/courses/:course_id/assessments", Instructors.AssessmentsLive, :index
      live "/instructor/courses/:course_id/assessments/new", Instructors.AssessmentsLive, :new
      live "/instructor/courses/:course_id/assessments/:id/edit", Instructors.AssessmentsLive, :edit

      live "/instructor/analytics", Instructors.AnalyticsLive, :index
      live "/instructor/analytics/course/:id", Instructors.AnalyticsLive, :course
    end
  end
end
