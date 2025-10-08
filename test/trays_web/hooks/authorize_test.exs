defmodule TraysWeb.Hooks.AuthorizeTest do
  use TraysWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Trays.Accounts

  describe "Hooks.Authorize" do
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

    test "allows access when user is authorized", %{conn: conn, merchant: merchant} do
      conn = log_in_user(conn, merchant)

      {:ok, _view, html} = live(conn, "/test-authorize")

      assert html =~ "Authorized Content"
    end

    test "denies access when user is not authorized", %{conn: conn, customer: customer} do
      conn = log_in_user(conn, customer)

      result = live(conn, "/test-authorize")

      assert {:error, {:redirect, %{to: "/", flash: flash}}} = result
      assert flash["error"] == "You are not authorized to access this page."
    end

    test "denies access when no user is logged in", %{conn: conn} do
      result = live(conn, "/test-authorize")

      # Should redirect to login page due to require_authenticated_user
      assert {:error, {:redirect, %{to: path}}} = result
      assert path == "/users/log-in"
    end

    test "admin can access merchant resources", %{conn: conn, admin: admin} do
      conn = log_in_user(conn, admin)

      {:ok, _view, html} = live(conn, "/test-authorize")

      assert html =~ "Authorized Content"
    end

    test "merchant can access menu management", %{conn: conn, merchant: merchant} do
      conn = log_in_user(conn, merchant)

      {:ok, _view, html} = live(conn, "/test-authorize")

      assert html =~ "Authorized Content"
    end

    test "customer cannot access merchant-only resources", %{conn: conn, customer: customer} do
      conn = log_in_user(conn, customer)

      result = live(conn, "/test-authorize")

      assert {:error, {:redirect, %{to: "/", flash: flash}}} = result
      assert flash["error"] == "You are not authorized to access this page."
    end

    test "flash error message is set correctly on unauthorized access", %{
      conn: conn,
      customer: customer
    } do
      conn = log_in_user(conn, customer)

      {:error, {:redirect, %{to: "/", flash: flash}}} = live(conn, "/test-authorize")

      assert flash["error"] == "You are not authorized to access this page."
    end

    test "redirects to root path on unauthorized access", %{conn: conn, customer: customer} do
      conn = log_in_user(conn, customer)

      {:error, {:redirect, %{to: path}}} = live(conn, "/test-authorize")

      assert path == "/"
    end

    test "halts the socket lifecycle on unauthorized access", %{conn: conn, customer: customer} do
      conn = log_in_user(conn, customer)

      # The hook should halt, preventing mount from completing
      result = live(conn, "/test-authorize")

      assert {:error, {:redirect, _}} = result
    end

    test "continues socket lifecycle on authorized access", %{conn: conn, merchant: merchant} do
      conn = log_in_user(conn, merchant)

      # The hook should continue, allowing mount to complete
      result = live(conn, "/test-authorize")

      assert {:ok, _view, _html} = result
    end

    test "handles nil user gracefully", %{conn: conn} do
      # Don't log in any user
      result = live(conn, "/test-authorize")

      # Should redirect to login due to require_authenticated_user hook
      assert {:error, {:redirect, %{to: path}}} = result
      assert path == "/users/log-in"
    end
  end

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

    test "merchant can view menus", %{merchant: merchant} do
      assert Accounts.can?(merchant, :view, :menu)
    end

    test "merchant can manage menus", %{merchant: merchant} do
      assert Accounts.can?(merchant, :manage, :menu)
    end

    test "merchant can view orders", %{merchant: merchant} do
      assert Accounts.can?(merchant, :view, :orders)
    end

    test "merchant can manage orders", %{merchant: merchant} do
      assert Accounts.can?(merchant, :manage, :orders)
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

  describe "Hooks.Authorize with current_scope" do
    setup do
      {:ok, merchant} =
        Accounts.register_user(%{
          email: "merchant@example.com",
          name: "Merchant User",
          phone_number: "5550001111",
          type: :merchant
        })

      %{merchant: merchant}
    end

    test "works with current_scope.user assignment", %{conn: conn, merchant: merchant} do
      conn = log_in_user(conn, merchant)

      {:ok, _view, html} = live(conn, "/test-authorize")

      assert html =~ "Authorized Content"
    end
  end

  describe "Hooks.Authorize with different action/resource combinations" do
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

    test "merchant can access view orders page", %{conn: conn, merchant: merchant} do
      conn = log_in_user(conn, merchant)

      {:ok, _view, html} = live(conn, "/test-view-orders")

      assert html =~ "View Orders Content"
    end

    test "merchant can access manage orders page", %{conn: conn, merchant: merchant} do
      conn = log_in_user(conn, merchant)

      {:ok, _view, html} = live(conn, "/test-manage-orders")

      assert html =~ "Manage Orders Content"
    end

    test "merchant can access view menu page", %{conn: conn, merchant: merchant} do
      conn = log_in_user(conn, merchant)

      {:ok, _view, html} = live(conn, "/test-view-menu")

      assert html =~ "View Menu Content"
    end

    test "customer can access create order page", %{conn: conn, customer: customer} do
      conn = log_in_user(conn, customer)

      {:ok, _view, html} = live(conn, "/test-create-order")

      assert html =~ "Create Order Content"
    end

    test "customer cannot access view orders page", %{conn: conn, customer: customer} do
      conn = log_in_user(conn, customer)

      result = live(conn, "/test-view-orders")

      assert {:error, {:redirect, %{to: "/", flash: flash}}} = result
      assert flash["error"] == "You are not authorized to access this page."
    end

    test "customer cannot access manage orders page", %{conn: conn, customer: customer} do
      conn = log_in_user(conn, customer)

      result = live(conn, "/test-manage-orders")

      assert {:error, {:redirect, %{to: "/", flash: flash}}} = result
      assert flash["error"] == "You are not authorized to access this page."
    end

    test "customer cannot access view menu page", %{conn: conn, customer: customer} do
      conn = log_in_user(conn, customer)

      result = live(conn, "/test-view-menu")

      assert {:error, {:redirect, %{to: "/", flash: flash}}} = result
      assert flash["error"] == "You are not authorized to access this page."
    end

    test "admin can access all pages - manage menu", %{conn: conn, admin: admin} do
      conn = log_in_user(conn, admin)

      {:ok, _view, html} = live(conn, "/test-authorize")

      assert html =~ "Authorized Content"
    end

    test "admin can access all pages - view orders", %{conn: conn, admin: admin} do
      conn = log_in_user(conn, admin)

      {:ok, _view, html} = live(conn, "/test-view-orders")

      assert html =~ "View Orders Content"
    end

    test "admin can access all pages - create order", %{conn: conn, admin: admin} do
      conn = log_in_user(conn, admin)

      {:ok, _view, html} = live(conn, "/test-create-order")

      assert html =~ "Create Order Content"
    end

    test "admin can access all pages - view menu", %{conn: conn, admin: admin} do
      conn = log_in_user(conn, admin)

      {:ok, _view, html} = live(conn, "/test-view-menu")

      assert html =~ "View Menu Content"
    end

    test "admin can access all pages - manage orders", %{conn: conn, admin: admin} do
      conn = log_in_user(conn, admin)

      {:ok, _view, html} = live(conn, "/test-manage-orders")

      assert html =~ "Manage Orders Content"
    end
  end

  describe "Hooks.Authorize params and session handling" do
    setup do
      {:ok, merchant} =
        Accounts.register_user(%{
          email: "merchant@example.com",
          name: "Merchant User",
          phone_number: "5550001111",
          type: :merchant
        })

      %{merchant: merchant}
    end

    test "ignores params passed to on_mount", %{conn: conn, merchant: merchant} do
      conn = log_in_user(conn, merchant)

      # The hook should ignore params and only check authorization
      {:ok, _view, html} = live(conn, "/test-authorize?foo=bar")

      assert html =~ "Authorized Content"
    end

    test "ignores session passed to on_mount", %{conn: conn, merchant: merchant} do
      conn = log_in_user(conn, merchant)

      # The hook receives session but doesn't use it
      {:ok, _view, html} = live(conn, "/test-authorize")

      assert html =~ "Authorized Content"
    end

    test "works with query params in URL", %{conn: conn, merchant: merchant} do
      conn = log_in_user(conn, merchant)

      {:ok, _view, html} = live(conn, "/test-authorize?id=123&name=test")

      assert html =~ "Authorized Content"
    end
  end

  describe "Hooks.Authorize return values" do
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

      %{merchant: merchant, customer: customer}
    end

    test "returns {:cont, socket} tuple on authorized access", %{conn: conn, merchant: merchant} do
      conn = log_in_user(conn, merchant)

      # Verify the hook returns continuation
      {:ok, view, _html} = live(conn, "/test-authorize")

      # If we got here, the hook returned {:cont, socket}
      assert view
    end

    test "returns {:halt, socket} tuple on unauthorized access", %{conn: conn, customer: customer} do
      conn = log_in_user(conn, customer)

      # Verify the hook returns halt with redirect
      result = live(conn, "/test-authorize")

      assert {:error, {:redirect, _}} = result
    end
  end

  describe "Hooks.Authorize authorization matrix" do
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

    # Test merchant permissions exhaustively
    test "merchant + manage + menu = authorized", %{conn: conn, merchant: merchant} do
      conn = log_in_user(conn, merchant)
      assert {:ok, _view, _html} = live(conn, "/test-authorize")
    end

    test "merchant + view + menu = authorized", %{conn: conn, merchant: merchant} do
      conn = log_in_user(conn, merchant)
      assert {:ok, _view, _html} = live(conn, "/test-view-menu")
    end

    test "merchant + view + orders = authorized", %{conn: conn, merchant: merchant} do
      conn = log_in_user(conn, merchant)
      assert {:ok, _view, _html} = live(conn, "/test-view-orders")
    end

    test "merchant + manage + orders = authorized", %{conn: conn, merchant: merchant} do
      conn = log_in_user(conn, merchant)
      assert {:ok, _view, _html} = live(conn, "/test-manage-orders")
    end

    test "merchant + create + order = unauthorized", %{conn: conn, merchant: merchant} do
      conn = log_in_user(conn, merchant)
      assert {:error, {:redirect, _}} = live(conn, "/test-create-order")
    end

    # Test customer permissions exhaustively
    test "customer + create + order = authorized", %{conn: conn, customer: customer} do
      conn = log_in_user(conn, customer)
      assert {:ok, _view, _html} = live(conn, "/test-create-order")
    end

    test "customer + manage + menu = unauthorized", %{conn: conn, customer: customer} do
      conn = log_in_user(conn, customer)
      assert {:error, {:redirect, _}} = live(conn, "/test-authorize")
    end

    test "customer + view + menu = unauthorized", %{conn: conn, customer: customer} do
      conn = log_in_user(conn, customer)
      assert {:error, {:redirect, _}} = live(conn, "/test-view-menu")
    end

    test "customer + view + orders = unauthorized", %{conn: conn, customer: customer} do
      conn = log_in_user(conn, customer)
      assert {:error, {:redirect, _}} = live(conn, "/test-view-orders")
    end

    test "customer + manage + orders = unauthorized", %{conn: conn, customer: customer} do
      conn = log_in_user(conn, customer)
      assert {:error, {:redirect, _}} = live(conn, "/test-manage-orders")
    end

    # Test admin has universal access
    test "admin + any combination = authorized (sample 1)", %{conn: conn, admin: admin} do
      conn = log_in_user(conn, admin)
      assert {:ok, _view, _html} = live(conn, "/test-authorize")
    end

    test "admin + any combination = authorized (sample 2)", %{conn: conn, admin: admin} do
      conn = log_in_user(conn, admin)
      assert {:ok, _view, _html} = live(conn, "/test-view-orders")
    end

    test "admin + any combination = authorized (sample 3)", %{conn: conn, admin: admin} do
      conn = log_in_user(conn, admin)
      assert {:ok, _view, _html} = live(conn, "/test-create-order")
    end
  end

  describe "Hooks.Authorize get_current_user branches" do
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

      %{merchant: merchant, customer: customer}
    end

    test "handles socket with current_user assignment (not current_scope)", %{
      conn: conn,
      merchant: merchant
    } do
      conn = log_in_user(conn, merchant)

      # This route uses a hook that converts current_scope to current_user
      {:ok, _view, html} = live(conn, "/test-current-user")

      assert html =~ "Current User Content"
    end

    test "handles socket with no user assignment", %{conn: conn, customer: customer} do
      conn = log_in_user(conn, customer)

      # This route uses a hook that removes all user assignments
      result = live(conn, "/test-no-user")

      # Should be unauthorized because no user is found
      assert {:error, {:redirect, %{to: "/", flash: flash}}} = result
      assert flash["error"] == "You are not authorized to access this page."
    end

    test "current_user path works with authorized merchant", %{conn: conn, merchant: merchant} do
      conn = log_in_user(conn, merchant)

      result = live(conn, "/test-current-user")

      assert {:ok, _view, html} = result
      assert html =~ "Current User Content"
    end

    test "nil user path triggers unauthorized", %{conn: conn, merchant: merchant} do
      conn = log_in_user(conn, merchant)

      result = live(conn, "/test-no-user")

      assert {:error, {:redirect, %{to: "/"}}} = result
    end
  end
end
