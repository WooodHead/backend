defmodule Re.Listings do
  @moduledoc """
  Context for listings.
  """
  @behaviour Bodyguard.Policy

  import Ecto.Query

  alias Re.{
    Listing,
    Listings.Filter,
    Images,
    Repo
  }

  alias Ecto.Changeset

  defdelegate authorize(action, user, params), to: Re.Listings.Policy

  def active_listings_query(query \\ Listing), do: from(l in query, where: l.is_active == true)

  def paginated(params \\ %{}) do
    active_listings_query()
    |> order_by_listing()
    |> Filter.apply(params)
    |> preload_listing()
    |> Repo.paginate(params)
  end

  def get(id), do: do_get(Listing, id)

  def get_preloaded(id), do: do_get(preload_listing(), id)

  def insert(listing_params, address, user) do
    %Listing{}
    |> Changeset.change(address_id: address.id)
    |> Changeset.change(user_id: user.id)
    |> Listing.changeset(listing_params, user.role)
    |> Repo.insert()
  end

  def update(listing, listing_params, address, user) do
    listing
    |> Changeset.change(address_id: address.id)
    |> Listing.changeset(listing_params, user.role)
    |> Repo.update()
  end

  def delete(listing) do
    listing
    |> Changeset.change(is_active: false)
    |> Repo.update()
  end

  def order_by_listing(query), do: order_by(query, [l], desc: l.score, asc: l.matterport_code)

  def preload_listing(query \\ Listing),
    do: preload(query, [:address, images: ^Images.order_by_position()])

  defp do_get(query, id) do
    case Repo.get(query, id) do
      nil -> {:error, :not_found}
      listing -> {:ok, listing}
    end
  end
end
