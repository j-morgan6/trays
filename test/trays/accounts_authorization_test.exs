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
      assert Accounts.can?(admin, :delete, :anything)
    end

    test "merchant can view and manage orders", %{merchant: merchant} do
      assert Accounts.can?(merchant, :view, :merchant)
      assert Accounts.can?(merchant, :manage, :merchant)
    end

    test "merchant cannot manage users", %{merchant: merchant} do
      refute Accounts.can?(merchant, :manage, :users)
    end

    test "merchant can view and manage merchant locations", %{merchant: merchant} do
      assert Accounts.can?(merchant, :view, :merchant_location)
      assert Accounts.can?(merchant, :manage, :merchant_location)
    end

    test "merchant can view and manage bank accounts", %{merchant: merchant} do
      assert Accounts.can?(merchant, :view, :bank_account)
      assert Accounts.can?(merchant, :manage, :bank_account)
    end

    test "store_manager can view and manage merchant locations", %{store_manager: manager} do
      assert Accounts.can?(manager, :view, :merchant_location)
      assert Accounts.can?(manager, :list, :merchant_locations)
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

    test "default case denies unknown permissions", %{customer: customer} do
      refute Accounts.can?(customer, :delete, :anything)
      refute Accounts.can?(customer, :unknown_action, :unknown_resource)
    end

    test "nil user cannot access anything" do
      refute Accounts.can?(nil, :view, :anything)
      refute Accounts.can?(nil, :manage, :anything)
    end

    test "merchant can view and manage invoices", %{merchant: merchant} do
      assert Accounts.can?(merchant, :view, :invoice)
      assert Accounts.can?(merchant, :manage, :invoice)
    end

    test "store_manager can manage merchant locations", %{store_manager: manager} do
      assert Accounts.can?(manager, :manage, :merchant_location)
    end

    test "store_manager can view and manage invoices", %{store_manager: manager} do
      assert Accounts.can?(manager, :view, :invoice)
      assert Accounts.can?(manager, :manage, :invoice)
    end

    test "customer can create orders", %{customer: customer} do
      assert Accounts.can?(customer, :create, :order)
    end

    test "customer can view their own orders", %{customer: customer} do
      assert Accounts.can?(customer, :view, {:order, customer.id})
    end

    test "customer cannot view other users' orders", %{customer: customer} do
      other_user_id = customer.id + 999
      refute Accounts.can?(customer, :view, {:order, other_user_id})
    end
  end

  describe "list_user_permissions/1" do
    setup do
      {:ok, admin} =
        Accounts.register_user(%{
          email: "admin_perms@example.com",
          name: "Admin User",
          phone_number: "5550001111",
          type: :admin
        })

      {:ok, merchant} =
        Accounts.register_user(%{
          email: "merchant_perms@example.com",
          name: "Merchant User",
          phone_number: "5550002222",
          type: :merchant
        })

      {:ok, store_manager} =
        Accounts.register_user(%{
          email: "manager_perms@example.com",
          name: "Store Manager User",
          phone_number: "5550004444",
          type: :store_manager
        })

      {:ok, customer} =
        Accounts.register_user(%{
          email: "customer_perms@example.com",
          name: "Customer User",
          phone_number: "5550003333",
          type: :customer
        })

      %{admin: admin, merchant: merchant, store_manager: store_manager, customer: customer}
    end

    test "returns manage all for admin users", %{admin: admin} do
      permissions = Accounts.list_user_permissions(admin)
      assert {:manage, :all} in permissions
    end

    test "returns merchant permissions for merchant users", %{merchant: merchant} do
      permissions = Accounts.list_user_permissions(merchant)

      assert {:view, :merchant} in permissions
      assert {:manage, :merchant} in permissions
      assert {:view, :merchant_location} in permissions
      assert {:manage, :merchant_location} in permissions
      assert {:view, :bank_account} in permissions
      assert {:manage, :bank_account} in permissions
      assert {:manage, :invoice} in permissions
    end

    test "returns store manager permissions for store_manager users", %{store_manager: manager} do
      permissions = Accounts.list_user_permissions(manager)

      assert {:view, :merchant_location} in permissions
      assert {:manage, :merchant_location} in permissions
      assert {:view, :bank_account} in permissions
      assert {:manage, :bank_account} in permissions
      assert {:manage, :invoice} in permissions
    end

    test "returns customer permissions for customer users", %{customer: customer} do
      permissions = Accounts.list_user_permissions(customer)

      assert {:create, :order} in permissions
      assert {:view, :own_orders} in permissions
    end

    test "returns empty list for unknown user types" do
      permissions = Accounts.list_user_permissions(%{type: :unknown})
      assert permissions == []
    end

    test "returns empty list for nil user" do
      permissions = Accounts.list_user_permissions(nil)
      assert permissions == []
    end
  end
end
