defmodule Trays.Repo.Migrations.CreateLineItems do
  use Ecto.Migration

  def change do
    create table(:line_items) do
      add :description, :string, null: false
      add :quantity, :integer, null: false
      add :amount, :integer, null: false
      add :invoice_id, references(:invoices, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:line_items, [:invoice_id])
  end
end
