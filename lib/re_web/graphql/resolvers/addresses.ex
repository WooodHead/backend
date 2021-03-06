defmodule ReWeb.Resolvers.Addresses do
  @moduledoc """
  Resolver module for addresses
  """

  def per_listing(listing, params, %{context: %{current_user: current_user}}) do
    admin? = is_admin(listing, current_user)

    {:address, Map.put(params, :has_admin_rights, admin?)}
  end

  defp is_admin(%{user_id: user_id}, %{id: user_id}), do: true
  defp is_admin(_, %{role: "admin"}), do: true
  defp is_admin(_, _), do: false
end
