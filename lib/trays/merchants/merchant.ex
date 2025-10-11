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
    |> validate_length(:name, min: 2, max: 100, message: "must be between 2 and 100 characters")
    |> validate_length(:description,
      min: 10,
      max: 500,
      message: "must be between 10 and 500 characters"
    )
    |> unique_constraint(:user_id, message: "You can only have one business")
    |> foreign_key_constraint(:user_id)
  end
end
