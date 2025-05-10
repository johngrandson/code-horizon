defmodule CodeHorizon.TemplatesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `CodeHorizon.Templates` context.
  """

  @doc """
  Generate a template.
  """
  def template_fixture(attrs \\ %{}) do
    {:ok, template} =
      attrs
      |> Enum.into(%{
        accent_color: "some accent_color",
        description: "some description",
        is_default: true,
        name: "some name",
        primary_color: "some primary_color"
      })
      |> CodeHorizon.Templates.create_template()

    template
  end
end
