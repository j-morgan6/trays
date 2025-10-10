defmodule Trays.MerchantLocationsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Trays.MerchantLocations` context.
  """

  alias Trays.MerchantLocations

  @doc """
  Generate a merchant_location.
  """
  def merchant_location_fixture(attrs \\ %{}) do
    user =
      Map.get_lazy(attrs, :user, fn ->
        Trays.AccountsFixtures.user_fixture(%{type: :merchant})
      end)

    merchant =
      Map.get_lazy(attrs, :merchant, fn ->
        Trays.MerchantsFixtures.merchant_fixture(%{user: user})
      end)

    attrs =
      attrs
      |> Map.delete(:user)
      |> Map.delete(:merchant)
      |> Enum.into(%{
        street1: "123 Main St",
        street2: "Unit 4",
        city: "Toronto",
        province: "ON",
        postal_code: "M5V 1A1",
        country: "Canada",
        merchant_id: merchant.id,
        user_id: user.id
      })

    {:ok, merchant_location} = MerchantLocations.create_merchant_location(attrs)

    merchant_location
  end
end
