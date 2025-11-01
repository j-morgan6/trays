defmodule Trays.Invoices.Invoice do
  use Ecto.Schema
  import Ecto.Changeset

  schema "invoices" do
    field :name, :string
    field :email, :string
    field :address, :string
    field :phone_number, :string
    field :number, :string
    field :gst_hst, Money.Ecto.Amount.Type, default: Money.new(0)
    field :total_amount, Money.Ecto.Amount.Type, default: Money.new(0)
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
      :terms,
      :delivery_date,
      :merchant_location_id
    ])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must be a valid email")
    |> validate_money(:gst_hst, greater_than_or_equal_to: Money.new(0))
    |> validate_money(:total_amount, greater_than: Money.new(0))
    |> unique_constraint(:number)
    |> foreign_key_constraint(:merchant_location_id)
  end

  defp validate_money(changeset, field, opts) do
    value = get_field(changeset, field)

    if is_struct(value, Money) do
      compare_value = opts[:greater_than] || opts[:greater_than_or_equal_to]

      cond do
        opts[:greater_than] && Money.compare(value, compare_value) != 1 ->
          add_error(changeset, field, "must be greater than #{Money.to_string(compare_value)}")

        opts[:greater_than_or_equal_to] && Money.compare(value, compare_value) == -1 ->
          add_error(
            changeset,
            field,
            "must be greater than or equal to #{Money.to_string(compare_value)}"
          )

        true ->
          changeset
      end
    else
      changeset
    end
  end
end
