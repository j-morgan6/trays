defmodule Trays.Merchants do
  @moduledoc """
  The Merchants context.
  """

  import Ecto.Query, warn: false
  alias Trays.Repo

  alias Trays.Merchants.Merchant

  @doc """
  Returns the list of merchants for a specific user.
  """
  def list_merchants(user_id) do
    Merchant
    |> where([m], m.user_id == ^user_id)
    |> Repo.all()
  end

  @doc """
  Gets a single merchant by ID (for admin access).

  Raises `Ecto.NoResultsError` if the Merchant does not exist.
  """
  def get_merchant!(id) do
    Repo.get!(Merchant, id)
  end

  @doc """
  Gets a single merchant for a specific user.

  For merchant owners: checks if merchant belongs to the user.
  For store managers: checks if user manages any location under this merchant.

  Raises `Ecto.NoResultsError` if the Merchant does not exist or user doesn't have access.
  """
  def get_merchant!(id, user_id) do
    Merchant
    |> join(:left, [m], ml in assoc(m, :merchant_locations))
    |> where([m, ml], m.id == ^id and (m.user_id == ^user_id or ml.user_id == ^user_id))
    |> distinct(true)
    |> Repo.one!()
  end

  @doc """
  Creates a merchant.
  """
  def create_merchant(attrs \\ %{}) do
    %Merchant{}
    |> Merchant.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a merchant.
  """
  def update_merchant(%Merchant{} = merchant, attrs) do
    merchant
    |> Merchant.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a merchant.
  """
  def delete_merchant(%Merchant{} = merchant) do
    Repo.delete(merchant)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking merchant changes.
  """
  def change_merchant(%Merchant{} = merchant, attrs \\ %{}) do
    Merchant.changeset(merchant, attrs)
  end

  @doc """
  Gets or creates a default merchant for the given user.
  """
  def get_or_create_default_merchant(user_id) do
    case Repo.get_by(Merchant, user_id: user_id) do
      nil ->
        {:ok, merchant} =
          create_merchant(%{
            user_id: user_id,
            name: "Default Merchant",
            description: "Default merchant account"
          })

        merchant

      merchant ->
        merchant
    end
  end

  @doc """
  Returns a list of {name, id} tuples for merchant dropdowns.
  Only returns merchants belonging to the specified user.
  """
  def get_merchants_for_select(user_id) do
    Merchant
    |> where([m], m.user_id == ^user_id)
    |> select([m], {m.name, m.id})
    |> order_by([m], m.name)
    |> Repo.all()
  end

  @doc """
  Returns merchants with their location counts for the specified user.
  """
  def list_merchants_with_location_counts(user_id) do
    Merchant
    |> where([m], m.user_id == ^user_id)
    |> join(:left, [m], ml in assoc(m, :merchant_locations))
    |> group_by([m], m.id)
    |> select([m, ml], %{merchant: m, location_count: count(ml.id)})
    |> Repo.all()
  end

  @doc """
  Returns all merchants with their location counts (for admin view).
  """
  def list_all_merchants_with_location_counts do
    Merchant
    |> join(:left, [m], ml in assoc(m, :merchant_locations))
    |> group_by([m], m.id)
    |> select([m, ml], %{merchant: m, location_count: count(ml.id)})
    |> Repo.all()
  end
end
