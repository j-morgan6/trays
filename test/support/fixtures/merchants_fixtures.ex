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
    user =
      Map.get_lazy(attrs, :user, fn ->
        Trays.AccountsFixtures.user_fixture(%{type: :merchant})
      end)

    attrs =
      attrs
      |> Map.delete(:user)
      |> Enum.into(%{
        name: "Test Merchant",
        description: "A test merchant description",
        user_id: user.id
      })

    {:ok, merchant} = Merchants.create_merchant(attrs)

    merchant
  end
end
