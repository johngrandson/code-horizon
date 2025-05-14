defmodule CodeHorizonWeb.MembershipJSON do
  @moduledoc """
  JSON view for membership controller responses.
  Handles serialization of organization data for API responses.
  """

  @doc """
  Renders a list of organizations.
  """
  def index(%{orgs: orgs}) do
    %{
      data: for(org <- orgs, do: data(org))
    }
  end

  @doc """
  Renders a single organization with membership details.
  """
  def show(%{org: org, membership: membership}) do
    %{
      data: data(org, membership)
    }
  end

  defp data(org, membership \\ nil) do
    base_data = %{
      id: org.id,
      name: org.name,
      slug: org.slug
    }

    if membership do
      Map.merge(base_data, %{
        role: membership.role,
        membership_id: membership.id,
        joined_at: format_datetime(membership.inserted_at)
      })
    else
      base_data
    end
  end

  defp format_datetime(datetime) when is_nil(datetime), do: nil
  defp format_datetime(datetime), do: DateTime.to_iso8601(datetime)
end
