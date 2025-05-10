defmodule CodeHorizon.Templates.UserTemplate do
  @moduledoc false
  use CodeHorizon.Schema

  typed_schema "user_templates" do
    field :is_active, :boolean, default: false

    belongs_to :user, CodeHorizon.Accounts.User
    belongs_to :template, CodeHorizon.Templates.Template

    timestamps()
  end

  @doc false
  def changeset(user_template, attrs) do
    user_template
    |> cast(attrs, [:user_id, :template_id, :is_active])
    |> validate_required([:user_id, :template_id])
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:template_id)
    |> unique_constraint([:user_id, :template_id])
  end
end
