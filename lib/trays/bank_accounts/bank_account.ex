defmodule Trays.BankAccounts.BankAccount do
  use Ecto.Schema
  import Ecto.Changeset

  schema "bank_accounts" do
    field :account_number, :string
    field :transit_number, :string
    field :institution_number, :string

    belongs_to :merchant_location, Trays.MerchantLocations.MerchantLocation

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(bank_account, attrs) do
    bank_account
    |> cast(attrs, [:account_number, :transit_number, :institution_number, :merchant_location_id])
    |> validate_required([:account_number, :transit_number, :institution_number, :merchant_location_id])
    |> foreign_key_constraint(:merchant_location_id)
  end
end
