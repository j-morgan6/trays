defmodule Trays.AccountsAuthorizationTest do
  use Trays.DataCase

  alias Trays.Accounts

  describe "can?/3 authorization" do
    setup do
      {:ok, admin} = Accounts.register_user(%{
        email: "admin@example.com",
        name: "Admin User",
        phone_number: "5550001111",
        type: :admin
      })

      {:ok, merchant} = Accounts.register_user(%{
        email: "merchant@example.com",
        name: "Merchant User",
        phone_number: "5550002222",
        type: :merchant
      })

      {:ok, customer} = Accounts.register_user(%{
        email: "customer@example.com",
        name: "Customer User",
        phone_number: "5550003333",
        type: :customer
      })

      %{admin: admin, merchant: merchant, customer: customer}
    end

    test "admin can do anything", %{admin: admin} do
      assert Accounts.can?(admin, :manage, :users)
      assert Accounts.can?(admin, :manage, :menu)
      assert Accounts.can?(admin, :manage, :orders)
      assert Accounts.can?(admin, :view, :orders)
      assert Accounts.can?(admin, :create, :order)
      assert Accounts.can?(admin, :delete, :anything)
    end

    test "merchant can manage menus", %{merchant: merchant} do
      assert Accounts.can?(merchant, :manage, :menu)
      assert Accounts.can?(merchant, :view, :menu)
    end

    test "merchant can view and manage orders", %{merchant: merchant} do
      assert Accounts.can?(merchant, :view, :orders)
      assert Accounts.can?(merchant, :manage, :orders)
    end

    test "merchant cannot manage users", %{merchant: merchant} do
      refute Accounts.can?(merchant, :manage, :users)
    end

    test "customer can create orders", %{customer: customer} do
      assert Accounts.can?(customer, :create, :order)
    end

    test "customer can view their own orders", %{customer: customer} do
      assert Accounts.can?(customer, :view, {:order, customer.id})
    end

    test "customer cannot view other users' orders", %{customer: customer} do
      other_user_id = -1
      refute Accounts.can?(customer, :view, {:order, other_user_id})
    end

    test "customer cannot manage menu", %{customer: customer} do
      refute Accounts.can?(customer, :manage, :menu)
      refute Accounts.can?(customer, :view, :menu)
    end

    test "customer cannot manage orders", %{customer: customer} do
      refute Accounts.can?(customer, :manage, :orders)
    end
  end
end
