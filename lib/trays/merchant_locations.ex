defmodule Trays.MerchantLocations do
  @moduledoc """
  The MerchantLocations context.
  """

  import Ecto.Query, warn: false
  alias Trays.Repo

  alias Trays.MerchantLocations.MerchantLocation

  @doc """
  Returns the list of merchant_locations.
  """
  def list_merchant_locations do
    Repo.all(MerchantLocation)
  end

  @doc """
  Gets a single merchant_location.

  Raises `Ecto.NoResultsError` if the Merchant location does not exist.
  """
  def get_merchant_location!(id) do
    Repo.get!(MerchantLocation, id)
  end

  @doc """
  Creates a merchant_location.
  """
  def create_merchant_location(attrs \\ %{}) do
    %MerchantLocation{}
    |> MerchantLocation.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a merchant_location.
  """
  def update_merchant_location(%MerchantLocation{} = merchant_location, attrs) do
    merchant_location
    |> MerchantLocation.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a merchant_location.
  """
  def delete_merchant_location(%MerchantLocation{} = merchant_location) do
    Repo.delete(merchant_location)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking merchant_location changes.
  """
  def change_merchant_location(%MerchantLocation{} = merchant_location, attrs \\ %{}) do
    MerchantLocation.changeset(merchant_location, attrs)
  end
end
