defmodule TraysWeb.Plugs.AuthorizeTest do
  use TraysWeb.ConnCase, async: true

  alias Trays.Accounts
  alias TraysWeb.Plugs.Authorize

  describe "authorize plug" do
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

    test "allows access when user is authorized", %{conn: conn, merchant: merchant} do
      conn =
        conn
        |> assign(:current_user, merchant)
        |> Authorize.call(action: :manage, resource: :menu)

      refute conn.halted
    end

    test "denies access when user is not authorized", %{conn: conn, customer: customer} do
      conn =
        conn
        |> Plug.Test.init_test_session(%{})
        |> Phoenix.ConnTest.fetch_flash()
        |> assign(:current_user, customer)
        |> Authorize.call(action: :manage, resource: :menu)

      assert conn.halted
      assert redirected_to(conn) == "/"

      assert Phoenix.Flash.get(conn.assigns.flash, :error) ==
               "You are not authorized to perform this action."
    end

    test "denies access when no user is present", %{conn: conn} do
      conn =
        conn
        |> Plug.Test.init_test_session(%{})
        |> Phoenix.ConnTest.fetch_flash()
        |> Authorize.call(action: :manage, resource: :menu)

      assert conn.halted
      assert redirected_to(conn) == "/"
    end
  end
end
