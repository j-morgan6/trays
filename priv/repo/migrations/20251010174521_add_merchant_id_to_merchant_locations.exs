defmodule Trays.Repo.Migrations.AddMerchantIdToMerchantLocations do
  use Ecto.Migration

  def change do
    alter table(:merchant_locations) do
      add :merchant_id, references(:merchants, on_delete: :delete_all), null: false
    end

    create index(:merchant_locations, [:merchant_id])
  end
end
