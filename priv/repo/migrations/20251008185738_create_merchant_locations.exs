defmodule Trays.Repo.Migrations.CreateMerchantLocations do
  use Ecto.Migration

  def change do
    create table(:merchant_locations) do
      add :street1, :string
      add :street2, :string
      add :city, :string
      add :province, :string
      add :postal_code, :string
      add :country, :string

      timestamps(type: :utc_datetime)
    end
  end
end
