defmodule Trays.Repo.Migrations.CreateBankAccounts do
  use Ecto.Migration

  def change do
    create table(:bank_accounts) do
      add :account_number, :string
      add :transit_number, :string
      add :institution_number, :string
      add :merchant_location_id, references(:merchant_locations, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:bank_accounts, [:merchant_location_id])
  end
end
