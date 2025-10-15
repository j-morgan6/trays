defmodule TraysWeb.Hooks.AuthorizeTest do
  use TraysWeb.ConnCase

  alias Trays.Accounts

  describe "Hooks.Authorize with different resources" do
    setup do
      {:ok, merchant} =
        Accounts.register_user(%{
          email: "merchant@example.com",
          name: "Merchant User",
          phone_number: "5550001111",
          type: :merchant
        })

      {:ok, customer} =
        Accounts.register_user(%{
          email: "customer@example.com",
          name: "Customer User",
          phone_number: "5550002222",
          type: :customer
        })

      {:ok, admin} =
        Accounts.register_user(%{
          email: "admin@example.com",
          name: "Admin User",
          phone_number: "5550003333",
          type: :admin
        })

      %{merchant: merchant, customer: customer, admin: admin}
    end

    test "merchant can view merchant", %{merchant: merchant} do
      assert Accounts.can?(merchant, :view, :merchant)
    end

    test "merchant can change merchant", %{merchant: merchant} do
      assert Accounts.can?(merchant, :manage, :merchant)
    end

    test "customer can create orders", %{customer: customer} do
      assert Accounts.can?(customer, :create, :order)
    end

    test "customer can view their own orders", %{customer: customer} do
      assert Accounts.can?(customer, :view, {:order, customer.id})
    end

    test "customer cannot view other user's orders", %{customer: customer} do
      other_user_id = Ecto.UUID.generate()
      refute Accounts.can?(customer, :view, {:order, other_user_id})
    end

    test "customer cannot manage menus", %{customer: customer} do
      refute Accounts.can?(customer, :manage, :menu)
    end

    test "customer cannot view menus", %{customer: customer} do
      refute Accounts.can?(customer, :view, :menu)
    end

    test "customer cannot manage orders", %{customer: customer} do
      refute Accounts.can?(customer, :manage, :orders)
    end

    test "admin can manage menus", %{admin: admin} do
      assert Accounts.can?(admin, :manage, :menu)
    end

    test "admin can view orders", %{admin: admin} do
      assert Accounts.can?(admin, :view, :orders)
    end

    test "admin can perform any action on any resource", %{admin: admin} do
      assert Accounts.can?(admin, :any_action, :any_resource)
      assert Accounts.can?(admin, :delete, :user)
      assert Accounts.can?(admin, :create, :merchant)
    end

    test "nil user cannot access anything" do
      refute Accounts.can?(nil, :view, :menu)
      refute Accounts.can?(nil, :manage, :order)
    end
  end
end
