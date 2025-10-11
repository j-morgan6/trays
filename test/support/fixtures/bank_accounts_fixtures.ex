defmodule Trays.BankAccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Trays.BankAccounts` context.
  """

  @doc """
  Generate a bank_account.
  """
  def bank_account_fixture(attrs \\ %{}) do
    merchant_location =
      attrs[:merchant_location] ||
        Trays.MerchantLocationsFixtures.merchant_location_fixture()

    attrs =
      Enum.into(attrs, %{
        account_number: "some account_number",
        institution_number: "some institution_number",
        transit_number: "some transit_number",
        merchant_location_id: merchant_location.id
      })

    {:ok, bank_account} = Trays.BankAccounts.create_bank_account(attrs)
    bank_account
  end
end
