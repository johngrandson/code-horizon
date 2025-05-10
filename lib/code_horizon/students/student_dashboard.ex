defmodule CodeHorizon.StudentDashboard do
  @moduledoc """
  A projection struct representing aggregated dashboard data for a student (Like a DTO).
  This is not persisted as an entity, but constructed on-demand from various domain sources.
  """

  @type t :: %__MODULE__{
          id: String.t(),
          enrolled_courses: [map()],
          upcoming_assessments: [map()],
          recent_activity: [map()],
          recommended_courses: [map()],
          learning_stats: map()
        }

  defstruct [
    :id,
    :enrolled_courses,
    :upcoming_assessments,
    :recent_activity,
    :recommended_courses,
    :learning_stats
  ]
end
