defmodule Re.Neighborhoods do
  @moduledoc """
  Context for neighborhoods.
  """

  import Ecto.Query

  alias Re.{
    Address,
    Listing,
    Repo
  }

  @all_query from(
               a in Address,
               join: l in Listing,
               where: l.address_id == a.id and l.is_active,
               select: a.neighborhood,
               distinct: a.neighborhood
             )

  def all do
    Repo.all(@all_query)
  end

  @doc """
  Temporary mapping to find nearby neighborhood
  """
  def nearby("Botafogo"), do: "Humaitá"
  def nearby("Copacabana"), do: "Ipanema"
  def nearby("Flamengo"), do: "Laranjeiras"
  def nearby("Gávea"), do: "Leblon"
  def nearby("Humaitá"), do: "Botafogo"
  def nearby("Ipanema"), do: "Copacabana"
  def nearby("Itanhangá"), do: "São Conrado"
  def nearby("Jardim Botânico"), do: "Lagoa"
  def nearby("Lagoa"), do: "Humaitá"
  def nearby("Laranjeiras"), do: "Flamengo"
  def nearby("Leblon"), do: "Gávea"
  def nearby("São Conrado"), do: "Itanhangá"
end
