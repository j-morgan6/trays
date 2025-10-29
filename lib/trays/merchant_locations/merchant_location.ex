defmodule Trays.MerchantLocations.MerchantLocation do
  use Ecto.Schema
  import Ecto.Changeset

  schema "merchant_locations" do
    field :street1, :string
    field :street2, :string
    field :city, :string
    field :province, :string
    field :postal_code, :string
    field :country, :string
    field :email, :string
    field :phone_number, :string

    belongs_to :manager, Trays.Accounts.User, foreign_key: :user_id
    belongs_to :merchant, Trays.Merchants.Merchant
    has_one :bank_account, Trays.BankAccounts.BankAccount

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(merchant_location, attrs) do
    merchant_location
    |> cast(attrs, [
      :street1,
      :street2,
      :city,
      :province,
      :postal_code,
      :country,
      :email,
      :phone_number,
      :merchant_id,
      :user_id
    ])
    |> validate_required([
      :street1,
      :city,
      :province,
      :postal_code,
      :country,
      :merchant_id
    ])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must be a valid email")
    |> foreign_key_constraint(:merchant_id)
    |> foreign_key_constraint(:user_id)
  end

  @doc false
  def delete_changeset(merchant_location, _attrs \\ %{}) do
    merchant_location
    |> change()
    |> no_assoc_constraint(:bank_account,
      name: :bank_accounts_merchant_location_id_fkey,
      message: "cannot delete location with associated bank account"
    )
  end
end
