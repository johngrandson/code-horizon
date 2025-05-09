defmodule CodeHorizon.EnrollmentsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `CodeHorizon.Enrollments` context.
  """

  @doc """
  Generate a enrollment.
  """
  def enrollment_fixture(attrs \\ %{}) do
    {:ok, enrollment} =
      attrs
      |> Enum.into(%{
        enrolled_at: ~U[2025-05-07 20:32:00Z],
        expires_at: ~U[2025-05-07 20:32:00Z],
        status: :active
      })
      |> CodeHorizon.Enrollments.create_enrollment()

    enrollment
  end
end
