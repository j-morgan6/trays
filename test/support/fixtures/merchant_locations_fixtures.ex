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
    attrs =
      Enum.into(attrs, %{
        street1: "123 Main St",
        street2: "Unit 4",
        city: "Toronto",
        province: "ON",
        postal_code: "M5V 1A1",
        country: "Canada"
      })

    {:ok, merchant_location} = MerchantLocations.create_merchant_location(attrs)

    merchant_location
  end
end
