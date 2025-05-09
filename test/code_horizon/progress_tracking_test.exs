defmodule CodeHorizon.ProgressTrackingTest do
  use CodeHorizon.DataCase

  alias CodeHorizon.ProgressTracking

  describe "progress" do
    alias CodeHorizon.ProgressTracking.Progress

    import CodeHorizon.ProgressTrackingFixtures

    @invalid_attrs %{completion_status: nil, percent_complete: nil, last_accessed_at: nil, completion_date: nil}

    test "list_progress/0 returns all progress" do
      progress = progress_fixture()
      assert ProgressTracking.list_progress() == [progress]
    end

    test "get_progress!/1 returns the progress with given id" do
      progress = progress_fixture()
      assert ProgressTracking.get_progress!(progress.id) == progress
    end

    test "create_progress/1 with valid data creates a progress" do
      valid_attrs = %{completion_status: :not_started, percent_complete: 42, last_accessed_at: ~U[2025-05-07 20:39:00Z], completion_date: ~U[2025-05-07 20:39:00Z]}

      assert {:ok, %Progress{} = progress} = ProgressTracking.create_progress(valid_attrs)
      assert progress.completion_status == :not_started
      assert progress.percent_complete == 42
      assert progress.last_accessed_at == ~U[2025-05-07 20:39:00Z]
      assert progress.completion_date == ~U[2025-05-07 20:39:00Z]
    end

    test "create_progress/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = ProgressTracking.create_progress(@invalid_attrs)
    end

    test "update_progress/2 with valid data updates the progress" do
      progress = progress_fixture()
      update_attrs = %{completion_status: :in_progress, percent_complete: 43, last_accessed_at: ~U[2025-05-08 20:39:00Z], completion_date: ~U[2025-05-08 20:39:00Z]}

      assert {:ok, %Progress{} = progress} = ProgressTracking.update_progress(progress, update_attrs)
      assert progress.completion_status == :in_progress
      assert progress.percent_complete == 43
      assert progress.last_accessed_at == ~U[2025-05-08 20:39:00Z]
      assert progress.completion_date == ~U[2025-05-08 20:39:00Z]
    end

    test "update_progress/2 with invalid data returns error changeset" do
      progress = progress_fixture()
      assert {:error, %Ecto.Changeset{}} = ProgressTracking.update_progress(progress, @invalid_attrs)
      assert progress == ProgressTracking.get_progress!(progress.id)
    end

    test "delete_progress/1 deletes the progress" do
      progress = progress_fixture()
      assert {:ok, %Progress{}} = ProgressTracking.delete_progress(progress)
      assert_raise Ecto.NoResultsError, fn -> ProgressTracking.get_progress!(progress.id) end
    end

    test "change_progress/1 returns a progress changeset" do
      progress = progress_fixture()
      assert %Ecto.Changeset{} = ProgressTracking.change_progress(progress)
    end
  end
end
