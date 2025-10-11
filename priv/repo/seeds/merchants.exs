alias Trays.Repo
alias Trays.Merchants.Merchant
alias Trays.MerchantLocations.MerchantLocation
alias Trays.BankAccounts.BankAccount
alias Trays.Accounts


debbie = Accounts.get_user_by_email("debbie@trays.ca")
marry = Accounts.get_user_by_email("mary@trays.ca")

apd =
  %Merchant{
    name: "Au Pain Doré",
    description:
      "Bakery location offering fresh bread, pastries & other sweets, plus a cafe with sandwiches & coffee.",
    user: debbie
  }
  |> Repo.insert!()

front = %MerchantLocation{
  street1: "81 Front Street E",
  city: "Toronto",
  province: "ON",
  postal_code: "M5E 1B8",
  country: "Canada",
  user: marry,
  merchant: apd
}
|> Repo.insert!()

%BankAccount{
  account_number: "1234567890",
  transit_number: "123456789",
  institution_number: "123456789",
  merchant_location: front
}
|> Repo.insert!()

bay = %MerchantLocation{
  street1: "222 Bay",
  city: "Toronto",
  province: "ON",
  postal_code: "M5K 1E5",
  country: "Canada",
  user: marry,
  merchant: apd,
}
|> Repo.insert!()

%BankAccount{
  account_number: "1234567890",
  transit_number: "123456789",
  institution_number: "123456789",
  merchant_location: bay
}
|> Repo.insert!()
