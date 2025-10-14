# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Trays.Repo.insert!(%Trays.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Trays.Repo
alias Trays.Accounts.User
alias Trays.Merchants.Merchant
alias Trays.MerchantLocations.MerchantLocation
alias Trays.BankAccounts.BankAccount

Repo.delete_all(BankAccount)
Repo.delete_all(MerchantLocation)
Repo.delete_all(Merchant)
Repo.delete_all(User)

Code.require_file("seeds/users.exs", __DIR__)
Code.require_file("seeds/merchants.exs", __DIR__)
