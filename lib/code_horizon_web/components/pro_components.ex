defmodule CodeHorizonComponents do
  @moduledoc false
  defmacro __using__(_) do
    quote do
      import CodeHorizonWeb.Aurora
      import CodeHorizonWeb.AuthLayout
      import CodeHorizonWeb.BorderBeam
      import CodeHorizonWeb.ColorSchemeSwitch
      import CodeHorizonWeb.ComboBox
      import CodeHorizonWeb.ContentEditor
      import CodeHorizonWeb.DataTable
      import CodeHorizonWeb.FeatureCards
      import CodeHorizonWeb.Flash
      import CodeHorizonWeb.FloatingDiv
      import CodeHorizonWeb.LanguageSelect
      import CodeHorizonWeb.LocalTime
      import CodeHorizonWeb.Markdown
      import CodeHorizonWeb.Navbar
      import CodeHorizonWeb.PageComponents
      import CodeHorizonWeb.RouteTree
      import CodeHorizonWeb.SidebarLayout
      import CodeHorizonWeb.SocialButton
      import CodeHorizonWeb.StackedLayout
    end
  end
end
