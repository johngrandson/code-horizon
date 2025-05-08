defmodule CodeHorizon.FilesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `CodeHorizon.Files` context.
  """

  @doc """
  Generate a file.
  """
  def file_fixture(attrs \\ %{}) do
    {:ok, file} =
      attrs
      |> Enum.into(%{
        name: "some name",
        url: "some url"
      })
      |> CodeHorizon.Files.create_file()

    file
  end
end
