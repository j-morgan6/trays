defmodule Trays.Invoices.LineItem do
  use Ecto.Schema
  import Ecto.Changeset

  schema "line_items" do
    field :description, :string
    field :quantity, :integer
    field :amount, Money.Ecto.Amount.Type, default: Money.new(0)

    belongs_to :invoice, Trays.Invoices.Invoice

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(line_item, attrs) do
    line_item
    |> cast(attrs, [:description, :quantity, :amount, :invoice_id])
    |> validate_required([:description, :quantity, :invoice_id])
    |> validate_number(:quantity, greater_than: 0)
    |> validate_money(:amount, greater_than: Money.new(0))
    |> foreign_key_constraint(:invoice_id)
  end

  @doc """
  Changeset for temporary line items that don't have an invoice_id yet.
  """
  def temp_changeset(line_item, attrs) do
    line_item
    |> cast(attrs, [:description, :quantity, :amount])
    |> validate_required([:description, :quantity, :amount])
    |> validate_number(:quantity, greater_than: 0)
    |> validate_money(:amount, greater_than: Money.new(0))
  end

  defp validate_money(changeset, field, opts) do
    value = get_field(changeset, field)

    if is_struct(value, Money) do
      compare_value = opts[:greater_than] || opts[:greater_than_or_equal_to]

      if opts[:greater_than] && Money.compare(value, compare_value) != 1 do
        add_error(changeset, field, "must be greater than #{Money.to_string(compare_value)}")
      else
        changeset
      end
    else
      changeset
    end
  end
end
