defmodule Trays.Repo.Migrations.ConvertInvoiceAmountsToMoney do
  use Ecto.Migration

  def up do
    # Add new integer columns for money amounts (stored in cents)
    alter table(:invoices) do
      add :gst_hst_cents, :integer
      add :total_amount_cents, :integer
    end

    # Convert existing decimal values to cents
    # Multiply by 100 and round to get integer cents from decimal dollars
    execute """
    UPDATE invoices
    SET gst_hst_cents = ROUND(gst_hst * 100),
        total_amount_cents = ROUND(total_amount * 100)
    """

    # Remove old decimal columns
    alter table(:invoices) do
      remove :gst_hst
      remove :total_amount
    end

    # Rename new columns to original names
    rename table(:invoices), :gst_hst_cents, to: :gst_hst
    rename table(:invoices), :total_amount_cents, to: :total_amount
  end

  def down do
    # Add back decimal columns
    alter table(:invoices) do
      add :gst_hst_decimal, :decimal, precision: 15, scale: 2
      add :total_amount_decimal, :decimal, precision: 15, scale: 2
    end

    # Convert cents back to decimal dollars
    execute """
    UPDATE invoices
    SET gst_hst_decimal = gst_hst / 100.0,
        total_amount_decimal = total_amount / 100.0
    """

    # Remove integer columns
    alter table(:invoices) do
      remove :gst_hst
      remove :total_amount
    end

    # Rename decimal columns to original names
    rename table(:invoices), :gst_hst_decimal, to: :gst_hst
    rename table(:invoices), :total_amount_decimal, to: :total_amount
  end
end
