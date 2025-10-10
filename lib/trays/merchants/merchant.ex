defmodule Trays.Merchants.Merchant do
  use Ecto.Schema
  import Ecto.Changeset

  schema "merchants" do
    field :name, :string
    field :description, :string

    belongs_to :user, Trays.Accounts.User
    has_many :merchant_locations, Trays.MerchantLocations.MerchantLocation

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(merchant, attrs) do
    merchant
    |> cast(attrs, [:name, :description, :user_id])
    |> validate_required([:name, :description, :user_id])
    |> foreign_key_constraint(:user_id)
  end
end
