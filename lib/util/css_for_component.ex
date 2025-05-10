defmodule CodeHorizonWeb.Util.CssForComponent do
  @moduledoc """
  Helper functions for managing application assets.
  """

  @doc """
  Loads CSS file content from priv/static.
  Returns the content or a fallback comment if file not found.

  ## Examples

      iex> load_css("components/dashboard.css")
      "/* CSS content here */"
  """
  def load_css(path) do
    css_path = Path.join(Application.app_dir(:code_horizon, "priv"), "static/assets/css/#{path}")

    case File.read(css_path) do
      {:ok, content} -> content
      _ -> "/* CSS file #{path} not found */"
    end
  end

  @doc """
  Returns a style tag with CSS content for a specific component.

  ## Examples

      iex> css_for_component("lms_dashboard")
      "<style>/* CSS content here */</style>"
  """
  def css_for_component(component_name) do
    component_name
    |> Kernel.<>(".css")
    |> load_css()
  end
end
