
alias Trays.Accounts

Accounts.register_user(%{
  name: "Cheezy Morgan",
  email: "cheezy@letstango.ca",
  phone_number: "647-992-2499",
  password: "change_me_cheezy",
  type: :admin
})

Accounts.register_user(%{
  name: "Ardita Karaj",
  email: "ardita@letstango.ca",
  phone_number: "416-230-4519",
  password: "change_me_ardita",
  type: :admin
})

Accounts.register_user(%{
  name: "Joseph Morgan",
  email: "joser.morgan6@gmail.com",
  phone_number: "647-594-4519",
  password: "change_me_joseph",
  type: :admin
})

Accounts.register_user(%{
  name: "Debbie Dore",
  email: "debbie@trays.ca",
  phone_number: "123-456-7890",
  password: "Debbie@123Pain",
  type: :merchant
})

Accounts.register_user(%{
  name: "Mary Manager",
  email: "mary@trays.ca",
  phone_number: "123-456-7890",
  password: "Mary@123Trays",
  type: :store_manager
})

Accounts.register_user(%{
  name: "Curious Customer",
  email: "Customer@trays.ca",
  phone_number: "123-456-7890",
  password: "customer@123Trays",
  type: :customer
})
