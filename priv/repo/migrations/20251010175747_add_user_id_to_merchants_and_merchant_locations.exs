defmodule Trays.Repo.Migrations.AddUserIdToMerchantsAndMerchantLocations do
  use Ecto.Migration

  def change do
    alter table(:merchants) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
    end

    alter table(:merchant_locations) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
    end

    create index(:merchants, [:user_id])
    create index(:merchant_locations, [:user_id])
  end
end
