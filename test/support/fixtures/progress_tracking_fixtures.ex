defmodule CodeHorizon.ProgressTrackingFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `CodeHorizon.ProgressTracking` context.
  """

  @doc """
  Generate a progress.
  """
  def progress_fixture(attrs \\ %{}) do
    {:ok, progress} =
      attrs
      |> Enum.into(%{
        completion_date: ~U[2025-05-07 20:39:00Z],
        completion_status: :not_started,
        last_accessed_at: ~U[2025-05-07 20:39:00Z],
        percent_complete: 42
      })
      |> CodeHorizon.ProgressTracking.create_progress()

    progress
  end
end
