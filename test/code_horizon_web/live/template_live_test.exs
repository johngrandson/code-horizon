defmodule CodeHorizonWeb.TemplateLiveTest do
  use CodeHorizonWeb.ConnCase

  import CodeHorizon.TemplatesFixtures
  import Phoenix.LiveViewTest

  @create_attrs %{
    name: "some name",
    description: "some description",
    primary_color: "some primary_color",
    accent_color: "some accent_color",
    is_default: true
  }
  @update_attrs %{
    name: "some updated name",
    description: "some updated description",
    primary_color: "some updated primary_color",
    accent_color: "some updated accent_color",
    is_default: false
  }
  @invalid_attrs %{name: nil, description: nil, primary_color: nil, accent_color: nil, is_default: false}

  defp create_template(_) do
    template = template_fixture()
    %{template: template}
  end

  describe "Index" do
    setup [:create_template]

    test "lists all templates", %{conn: conn, template: template} do
      {:ok, _index_live, html} = live(conn, ~p"/app/templates")

      assert html =~ "Listing Templates"
      assert html =~ template.name
    end

    test "saves new template", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/app/templates")

      assert index_live |> element("a", "New Template") |> render_click() =~
               "New Template"

      assert_patch(index_live, ~p"/app/templates/new")

      assert index_live
             |> form("#template-form", template: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#template-form", template: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/app/templates")

      html = render(index_live)
      assert html =~ "Template created successfully"
      assert html =~ "some name"
    end

    test "updates template in listing", %{conn: conn, template: template} do
      {:ok, index_live, _html} = live(conn, ~p"/app/templates")

      assert index_live |> element("a[href='/templates/#{template.id}/edit']", "Edit") |> render_click() =~
               "Edit Template"

      assert_patch(index_live, ~p"/app/templates/#{template}/edit")

      assert index_live
             |> form("#template-form", template: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#template-form", template: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/app/templates")

      html = render(index_live)
      assert html =~ "Template updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes template in listing", %{conn: conn, template: template} do
      {:ok, index_live, _html} = live(conn, ~p"/app/templates")

      assert index_live |> element("#templates-#{template.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "a[phx-value-id=#{template.id}]")
    end
  end

  describe "Show" do
    setup [:create_template]

    test "displays template", %{conn: conn, template: template} do
      {:ok, _show_live, html} = live(conn, ~p"/app/templates/#{template}")

      assert html =~ "Show Template"
      assert html =~ template.name
    end

    test "updates template within modal", %{conn: conn, template: template} do
      {:ok, show_live, _html} = live(conn, ~p"/app/templates/#{template}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Template"

      assert_patch(show_live, ~p"/app/templates/#{template}/show/edit")

      assert show_live
             |> form("#template-form", template: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#template-form", template: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/app/templates/#{template}")

      html = render(show_live)
      assert html =~ "Template updated successfully"
      assert html =~ "some updated name"
    end
  end
end
