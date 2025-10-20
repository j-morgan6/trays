defmodule Trays.Repo.Migrations.AddEmailAndPhoneToMerchantLocations do
  use Ecto.Migration

  def change do
    alter table(:merchant_locations) do
      add :email, :string
      add :phone_number, :string
    end
  end
end
