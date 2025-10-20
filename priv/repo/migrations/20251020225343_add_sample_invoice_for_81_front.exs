defmodule Trays.Repo.Migrations.AddSampleInvoiceFor81Front do
  use Ecto.Migration

  def up do
    execute """
    INSERT INTO invoices (
      name,
      email,
      address,
      phone_number,
      number,
      gst_hst,
      total_amount,
      terms,
      delivery_date,
      status,
      merchant_location_id,
      inserted_at,
      updated_at
    )
    SELECT
      'Coffee Bean Co.',
      'orders@coffeebeancompany.com',
      '789 Queen St W, Toronto, ON M6J 1G1',
      '416-555-7890',
      'INV-2025-001',
      65.00,
      565.00,
      'net30',
      '2025-01-20',
      'outstanding',
      id,
      NOW(),
      NOW()
    FROM merchant_locations
    WHERE street1 = '81 Front Street E'
    """
  end

  def down do
    execute """
    DELETE FROM invoices WHERE number = 'INV-2025-001'
    """
  end
end
