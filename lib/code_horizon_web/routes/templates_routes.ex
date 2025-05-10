defmodule CodeHorizonWeb.TemplatesRoutes do
  @moduledoc """
  Routes related to the templates
  """

  defmacro __using__(_opts) do
    quote do
      live "/templates", TemplateLive.Index, :index
      live "/templates/new", TemplateLive.Index, :new
      live "/templates/:id/edit", TemplateLive.Index, :edit

      live "/templates/:id", TemplateLive.Show, :show
      live "/templates/:id/show/edit", TemplateLive.Show, :edit
    end
  end
end
