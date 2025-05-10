defmodule CodeHorizon.Templates do
  @moduledoc """
  The Templates context.
  """

  import Ecto.Query, warn: false

  alias CodeHorizon.Accounts.User
  alias CodeHorizon.Repo
  alias CodeHorizon.Templates.Template
  alias CodeHorizon.Templates.UserTemplate

  @doc """
  Returns the list of templates.

  ## Examples

      iex> list_templates()
      [%Template{}, ...]

  """
  def list_templates do
    Repo.all(Template)
  end

  @doc """
  Gets the default template
  """
  def get_default_template do
    Repo.get_by(Template, is_default: true) ||
      case list_templates() do
        [first | _] -> first
        _ -> nil
      end
  end

  @doc """
  Gets the active template for a user
  """
  def get_active_template_for_user(%User{} = user) do
    query =
      from ut in UserTemplate,
        join: t in assoc(ut, :template),
        where: ut.user_id == ^user.id and ut.is_active == true,
        preload: [template: t]

    case Repo.one(query) do
      %UserTemplate{template: template} -> template
      _ -> get_default_template()
    end
  end

  @doc """
  Sets a template as active for a user
  """
  def set_active_template_for_user(%User{} = user, %Template{} = template) do
    # First, deactivate all templates for the user
    Repo.update_all(from(ut in UserTemplate, where: ut.user_id == ^user.id), set: [is_active: false])

    # Then, find or create and activate the selected template
    case Repo.get_by(UserTemplate, user_id: user.id, template_id: template.id) do
      nil ->
        %UserTemplate{}
        |> UserTemplate.changeset(%{user_id: user.id, template_id: template.id, is_active: true})
        |> Repo.insert()

      user_template ->
        user_template
        |> UserTemplate.changeset(%{is_active: true})
        |> Repo.update()
    end
  end

  @doc """
  Lists all templates available to a user (system templates + user created templates)
  """
  def list_templates_for_user(%User{} = user) do
    # Get all templates the user can access (system templates + their created ones)
    query =
      from t in Template,
        where: is_nil(t.created_by_id) or t.created_by_id == ^user.id,
        order_by: [desc: t.is_default, asc: t.name]

    templates = Repo.all(query)

    # Get the user's active template id
    active_template_id =
      case get_active_template_for_user(user) do
        %Template{id: id} -> id
        _ -> nil
      end

    # Mark the active template
    Enum.map(templates, fn template ->
      Map.put(template, :is_active, template.id == active_template_id)
    end)
  end

  @doc """
  Creates a template for a user
  """
  def create_user_template(%User{} = user, attrs) do
    attrs = Map.put(attrs, "created_by_id", user.id)

    %Template{}
    |> Template.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Gets a single template.

  Raises `Ecto.NoResultsError` if the Template does not exist.

  ## Examples

      iex> get_template!(123)
      %Template{}

      iex> get_template!(456)
      ** (Ecto.NoResultsError)

  """
  def get_template!(id), do: Repo.get!(Template, id)

  @doc """
  Creates a template.

  ## Examples

      iex> create_template(%{field: value})
      {:ok, %Template{}}

      iex> create_template(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_template(attrs \\ %{}) do
    %Template{}
    |> Template.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a template.

  ## Examples

      iex> update_template(template, %{field: new_value})
      {:ok, %Template{}}

      iex> update_template(template, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_template(%Template{} = template, attrs) do
    template
    |> Template.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a template.

  ## Examples

      iex> delete_template(template)
      {:ok, %Template{}}

      iex> delete_template(template)
      {:error, %Ecto.Changeset{}}

  """
  def delete_template(%Template{} = template) do
    Repo.delete(template)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking template changes.

  ## Examples

      iex> change_template(template)
      %Ecto.Changeset{data: %Template{}}

  """
  def change_template(%Template{} = template, attrs \\ %{}) do
    Template.changeset(template, attrs)
  end
end
