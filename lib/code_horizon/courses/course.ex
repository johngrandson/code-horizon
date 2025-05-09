defmodule CodeHorizon.Courses.Course do
  @moduledoc false
  use CodeHorizon.Schema

  import Ecto.Changeset

  alias CodeHorizon.Accounts.User

  typed_schema "courses" do
    field :level, Ecto.Enum, values: [:beginner, :intermediate, :advanced]
    field :description, :string
    field :title, :string

    field :cover_image, :string,
      default:
        "https://images.unsplash.com/photo-1503023345310-bd7c1de61c7d?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2070&q=80"

    field :is_published, :boolean, default: false
    field :featured_order, :integer
    field :slug, :string

    belongs_to :instructor, User

    timestamps()
  end

  @doc false
  def changeset(course, attrs) do
    course
    |> cast(attrs, [:title, :cover_image, :description, :level, :is_published, :featured_order, :slug])
    |> validate_required([:title, :description, :level, :is_published, :featured_order])
    |> generate_slug()
    |> unique_constraint(:slug)
  end

  # generate a URL friendly slug from the course title
  defp generate_slug(%Ecto.Changeset{valid?: true, changes: %{title: title}} = changeset) do
    short_uuid = Ecto.UUID.generate() |> String.split("-") |> List.first()

    slug =
      title
      |> String.downcase()
      |> String.replace(~r/[^a-z0-9\s-]/, "")
      |> String.replace(~r/\s+/, "-")
      |> Kernel.<>("-#{short_uuid}")

    put_change(changeset, :slug, slug)
  end

  defp generate_slug(changeset), do: changeset
end
