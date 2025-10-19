defmodule Trays.Repo.Migrations.CreateInvoices do
  use Ecto.Migration

  def change do
    create table(:invoices) do
      add :name, :string, null: false
      add :email, :string, null: false
      add :address, :text, null: false
      add :phone_number, :string, null: false
      add :number, :string, null: false
      add :gst_hst, :decimal, precision: 10, scale: 2, null: false
      add :total_amount, :decimal, precision: 10, scale: 2, null: false
      add :terms, :string, null: false
      add :delivery_date, :date, null: false
      add :status, :string, null: false, default: "outstanding"

      add :merchant_location_id, references(:merchant_locations, on_delete: :delete_all),
        null: false

      timestamps(type: :utc_datetime)
    end

    create index(:invoices, [:merchant_location_id])
    create unique_index(:invoices, [:number])
  end
end
