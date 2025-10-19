defmodule Trays.Invoices.Invoice do
  use Ecto.Schema
  import Ecto.Changeset

  schema "invoices" do
    field :name, :string
    field :email, :string
    field :address, :string
    field :phone_number, :string
    field :number, :string
    field :gst_hst, :decimal
    field :total_amount, :decimal
    field :terms, Ecto.Enum, values: [:now, :net15, :net30]
    field :delivery_date, :date
    field :status, Ecto.Enum, values: [:outstanding, :paid], default: :outstanding

    belongs_to :merchant_location, Trays.MerchantLocations.MerchantLocation

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(invoice, attrs) do
    invoice
    |> cast(attrs, [
      :name,
      :email,
      :address,
      :phone_number,
      :number,
      :gst_hst,
      :total_amount,
      :terms,
      :delivery_date,
      :status,
      :merchant_location_id
    ])
    |> validate_required([
      :name,
      :email,
      :address,
      :phone_number,
      :number,
      :gst_hst,
      :total_amount,
      :terms,
      :delivery_date,
      :merchant_location_id
    ])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must be a valid email")
    |> validate_number(:gst_hst, greater_than_or_equal_to: 0)
    |> validate_number(:total_amount, greater_than: 0)
    |> unique_constraint(:number)
    |> foreign_key_constraint(:merchant_location_id)
  end
end
