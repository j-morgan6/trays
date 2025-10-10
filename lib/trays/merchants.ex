defmodule Trays.Merchants do
  @moduledoc """
  The Merchants context.
  """

  import Ecto.Query, warn: false
  alias Trays.Repo

  alias Trays.Merchants.Merchant

  @doc """
  Returns the list of merchants.
  """
  def list_merchants do
    Repo.all(Merchant)
  end

  @doc """
  Gets a single merchant.

  Raises `Ecto.NoResultsError` if the Merchant does not exist.
  """
  def get_merchant!(id) do
    Repo.get!(Merchant, id)
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
end
