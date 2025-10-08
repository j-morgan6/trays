defmodule Trays.Repo.Migrations.CreateMerchants do
  use Ecto.Migration

  def change do
    create table(:merchants) do
      add :name, :string
      add :description, :string

      timestamps(type: :utc_datetime)
    end
  end
end
