defmodule Trays.MerchantsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Trays.Merchants` context.
  """

  alias Trays.Merchants

  @doc """
  Generate a merchant.
  """
  def merchant_fixture(attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        name: "Test Merchant",
        description: "A test merchant description"
      })

    {:ok, merchant} = Merchants.create_merchant(attrs)

    merchant
  end
end
