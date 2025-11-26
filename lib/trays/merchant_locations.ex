defmodule Trays.MerchantLocations do
  @moduledoc """
  The MerchantLocations context.
  """

  import Ecto.Query, warn: false
  alias Trays.Repo

  alias Trays.MerchantLocations.MerchantLocation

  @doc """
  Returns all merchant_locations (for admin access).
  Preloads the merchant association.
  """
  def list_all_merchant_locations do
    MerchantLocation
    |> preload(:merchant)
    |> Repo.all()
  end

  @doc """
  Returns the list of merchant_locations for a specific user.
  Preloads the merchant association.

  Returns locations where the user:
  - Is the direct manager (user_id matches), OR
  - Owns the merchant that the location belongs to
  """
  def list_merchant_locations(user_id) do
    MerchantLocation
    |> join(:inner, [ml], m in assoc(ml, :merchant))
    |> where([ml, m], ml.user_id == ^user_id or m.user_id == ^user_id)
    |> preload(:merchant)
    |> Repo.all()
  end

  @doc """
  Gets a single merchant_location by ID (for admin access).
  Preloads the merchant, bank_account, and manager associations.

  Raises `Ecto.NoResultsError` if the Merchant location does not exist.
  """
  def get_merchant_location!(id) do
    MerchantLocation
    |> where([ml], ml.id == ^id)
    |> preload([:merchant, :bank_account, :manager])
    |> Repo.one!()
  end

  @doc """
  Gets a single merchant_location for a specific user.
  Preloads the merchant, bank_account, and manager associations.

  The user can access the location if:
  - They are the direct manager (user_id matches), OR
  - They own the merchant that the location belongs to

  Raises `Ecto.NoResultsError` if the Merchant location does not exist or user doesn't have access.
  """
  def get_merchant_location!(id, user_id) do
    MerchantLocation
    |> join(:inner, [ml], m in assoc(ml, :merchant))
    |> where([ml, m], ml.id == ^id and (ml.user_id == ^user_id or m.user_id == ^user_id))
    |> preload([:merchant, :bank_account, :manager])
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
    merchant_location
    |> MerchantLocation.delete_changeset(%{})
    |> Repo.delete()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking merchant_location changes.
  """
  def change_merchant_location(%MerchantLocation{} = merchant_location, attrs \\ %{}) do
    MerchantLocation.changeset(merchant_location, attrs)
  end

  @doc """
  Returns the list of merchant_locations for a specific merchant.
  For store managers, only returns locations they manage.
  For merchant owners, returns all locations.
  """
  def list_merchant_locations_by_merchant(merchant_id, user_id, user_type) do
    query =
      MerchantLocation
      |> where([ml], ml.merchant_id == ^merchant_id)
      |> preload(:merchant)

    query =
      if user_type == :store_manager do
        where(query, [ml], ml.user_id == ^user_id)
      else
        query
      end

    Repo.all(query)
  end
end
