defmodule Trays.AccountsAuthorizationTest do
  use Trays.DataCase

  alias Trays.Accounts

  describe "can?/3 authorization" do
    setup do
      {:ok, admin} =
        Accounts.register_user(%{
          email: "admin@example.com",
          name: "Admin User",
          phone_number: "5550001111",
          type: :admin
        })

      {:ok, merchant} =
        Accounts.register_user(%{
          email: "merchant@example.com",
          name: "Merchant User",
          phone_number: "5550002222",
          type: :merchant
        })

      {:ok, store_manager} =
        Accounts.register_user(%{
          email: "manager@example.com",
          name: "Store Manager User",
          phone_number: "5550004444",
          type: :store_manager
        })

      {:ok, customer} =
        Accounts.register_user(%{
          email: "customer@example.com",
          name: "Customer User",
          phone_number: "5550003333",
          type: :customer
        })

      %{admin: admin, merchant: merchant, store_manager: store_manager, customer: customer}
    end

    test "admin can do anything", %{admin: admin} do
      assert Accounts.can?(admin, :manage, :users)
      assert Accounts.can?(admin, :manage, :menu)
      assert Accounts.can?(admin, :manage, :orders)
      assert Accounts.can?(admin, :view, :orders)
      assert Accounts.can?(admin, :create, :order)
      assert Accounts.can?(admin, :delete, :anything)
    end

    test "merchant can view and manage orders", %{merchant: merchant} do
      assert Accounts.can?(merchant, :view, :merchant)
      assert Accounts.can?(merchant, :manage, :merchant)
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

    test "merchant can view and manage merchant locations", %{merchant: merchant} do
      assert Accounts.can?(merchant, :view, :merchant_location)
      assert Accounts.can?(merchant, :manage, :merchant_location)
    end

    test "merchant can view and manage bank accounts", %{merchant: merchant} do
      assert Accounts.can?(merchant, :view, :bank_account)
      assert Accounts.can?(merchant, :manage, :bank_account)
    end

    test "store_manager can manage and view menus", %{store_manager: manager} do
      assert Accounts.can?(manager, :manage, :menu)
      assert Accounts.can?(manager, :view, :menu)
    end

    test "store_manager can view and manage orders", %{store_manager: manager} do
      assert Accounts.can?(manager, :view, :orders)
      assert Accounts.can?(manager, :manage, :orders)
    end

    test "store_manager can view and manage merchant locations", %{store_manager: manager} do
      assert Accounts.can?(manager, :view, :merchant_location)
      assert Accounts.can?(manager, :manage, :merchant_location)
    end

    test "store_manager can view and manage bank accounts", %{store_manager: manager} do
      assert Accounts.can?(manager, :view, :bank_account)
      assert Accounts.can?(manager, :manage, :bank_account)
    end

    test "store_manager cannot manage users", %{store_manager: manager} do
      refute Accounts.can?(manager, :manage, :users)
    end

    test "store_manager cannot view merchants", %{store_manager: manager} do
      refute Accounts.can?(manager, :view, :merchant)
    end

    test "merchant cannot view or manage menus", %{merchant: merchant} do
      refute Accounts.can?(merchant, :view, :menu)
      refute Accounts.can?(merchant, :manage, :menu)
    end

    test "merchant cannot view or manage orders", %{merchant: merchant} do
      refute Accounts.can?(merchant, :view, :orders)
      refute Accounts.can?(merchant, :manage, :orders)
    end

    test "default case denies unknown permissions", %{customer: customer} do
      refute Accounts.can?(customer, :delete, :anything)
      refute Accounts.can?(customer, :unknown_action, :unknown_resource)
    end

    test "nil user cannot access anything" do
      refute Accounts.can?(nil, :view, :anything)
      refute Accounts.can?(nil, :manage, :anything)
    end
  end
end
