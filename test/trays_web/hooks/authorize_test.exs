defmodule TraysWeb.Hooks.AuthorizeTest do
  use TraysWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Trays.Accounts

  describe "Hooks.Authorize" do
    setup do
      {:ok, merchant} = Accounts.register_user(%{
        email: "merchant@example.com",
        name: "Merchant User",
        phone_number: "5550001111",
        type: :merchant
      })

      {:ok, customer} = Accounts.register_user(%{
        email: "customer@example.com",
        name: "Customer User",
        phone_number: "5550002222",
        type: :customer
      })

      {:ok, admin} = Accounts.register_user(%{
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
  end
end
