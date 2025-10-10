defmodule Trays.MerchantLocations do
  @moduledoc """
  The MerchantLocations context.
  """

  import Ecto.Query, warn: false
  alias Trays.Repo

  alias Trays.MerchantLocations.MerchantLocation

  @doc """
  Returns the list of merchant_locations for a specific user.
  Preloads the merchant association.
  """
  def list_merchant_locations(user_id) do
    MerchantLocation
    |> where([ml], ml.user_id == ^user_id)
    |> preload(:merchant)
    |> Repo.all()
  end

  @doc """
  Gets a single merchant_location for a specific user.
  Preloads the merchant association.

  Raises `Ecto.NoResultsError` if the Merchant location does not exist or doesn't belong to the user.
  """
  def get_merchant_location!(id, user_id) do
    MerchantLocation
    |> where([ml], ml.id == ^id and ml.user_id == ^user_id)
    |> preload(:merchant)
    |> Repo.one!()
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

  @doc """
  Returns the list of merchant_locations for a specific merchant.
  Ensures the merchant belongs to the user.
  """
  def list_merchant_locations_by_merchant(merchant_id, user_id) do
    MerchantLocation
    |> where([ml], ml.merchant_id == ^merchant_id and ml.user_id == ^user_id)
    |> preload(:merchant)
    |> Repo.all()
  end
end
