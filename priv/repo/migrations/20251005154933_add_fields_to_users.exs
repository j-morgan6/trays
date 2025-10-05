defmodule Trays.Repo.Migrations.AddFieldsToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :name, :string, null: false
      add :phone_number, :string, null: false
      add :type, :string, null: false
    end

    create index(:users, [:type])
  end
end
