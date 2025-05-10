defmodule CodeHorizon.TemplatesTest do
  use CodeHorizon.DataCase

  alias CodeHorizon.Templates

  describe "templates" do
    alias CodeHorizon.Templates.Template

    import CodeHorizon.TemplatesFixtures

    @invalid_attrs %{name: nil, description: nil, primary_color: nil, accent_color: nil, is_default: nil}

    test "list_templates/0 returns all templates" do
      template = template_fixture()
      assert Templates.list_templates() == [template]
    end

    test "get_template!/1 returns the template with given id" do
      template = template_fixture()
      assert Templates.get_template!(template.id) == template
    end

    test "create_template/1 with valid data creates a template" do
      valid_attrs = %{name: "some name", description: "some description", primary_color: "some primary_color", accent_color: "some accent_color", is_default: true}

      assert {:ok, %Template{} = template} = Templates.create_template(valid_attrs)
      assert template.name == "some name"
      assert template.description == "some description"
      assert template.primary_color == "some primary_color"
      assert template.accent_color == "some accent_color"
      assert template.is_default == true
    end

    test "create_template/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Templates.create_template(@invalid_attrs)
    end

    test "update_template/2 with valid data updates the template" do
      template = template_fixture()
      update_attrs = %{name: "some updated name", description: "some updated description", primary_color: "some updated primary_color", accent_color: "some updated accent_color", is_default: false}

      assert {:ok, %Template{} = template} = Templates.update_template(template, update_attrs)
      assert template.name == "some updated name"
      assert template.description == "some updated description"
      assert template.primary_color == "some updated primary_color"
      assert template.accent_color == "some updated accent_color"
      assert template.is_default == false
    end

    test "update_template/2 with invalid data returns error changeset" do
      template = template_fixture()
      assert {:error, %Ecto.Changeset{}} = Templates.update_template(template, @invalid_attrs)
      assert template == Templates.get_template!(template.id)
    end

    test "delete_template/1 deletes the template" do
      template = template_fixture()
      assert {:ok, %Template{}} = Templates.delete_template(template)
      assert_raise Ecto.NoResultsError, fn -> Templates.get_template!(template.id) end
    end

    test "change_template/1 returns a template changeset" do
      template = template_fixture()
      assert %Ecto.Changeset{} = Templates.change_template(template)
    end
  end
end
