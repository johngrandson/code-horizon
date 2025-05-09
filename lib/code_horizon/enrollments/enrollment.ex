defmodule CodeHorizon.Enrollments.Enrollment do
  @moduledoc false
  use CodeHorizon.Schema

  alias CodeHorizon.Accounts.User
  alias CodeHorizon.Courses.Course
  alias CodeHorizon.Enrollments.EnrollmentStatus

  typed_schema "enrollments" do
    field :status, Ecto.Enum, values: EnrollmentStatus.all(), default: :active
    field :enrolled_at, :utc_datetime
    field :expires_at, :utc_datetime

    belongs_to :student, User
    belongs_to :course, Course

    timestamps()
  end

  @doc false
  def changeset(enrollment, attrs) do
    enrollment
    |> cast(attrs, [:status, :enrolled_at, :expires_at, :student_id, :course_id])
    |> validate_required([:status, :enrolled_at, :expires_at, :student_id, :course_id])
  end
end
