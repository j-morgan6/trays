defmodule TraysWeb.UserAuthRedirectTest do
  use TraysWeb.ConnCase, async: true

  alias Trays.Accounts

  describe "merchant login redirect" do
    setup do
      %{
        merchant:
          Accounts.register_user(%{
            email: "merchant@test.com",
            password: "passwordpassword",
            name: "Test Merchant",
            phone_number: "123-456-7890",
            type: :merchant
          })
          |> elem(1)
      }
    end

    test "redirects merchant to their merchant show page", %{conn: conn, merchant: merchant} do
      conn =
        post(conn, ~p"/users/log-in", %{
          "user" => %{
            "email" => merchant.email,
            "password" => "passwordpassword"
          }
        })

      assert redirected_to(conn) =~ ~r{/merchants/\d+}
    end

    test "merchant cannot access admin routes and user_return_to is cleared", %{
      conn: conn,
      merchant: merchant
    } do
      conn = log_in_user(conn, merchant)

      conn = get(conn, ~p"/merchants")
      assert redirected_to(conn) == ~p"/"
      assert Phoenix.Flash.get(conn.assigns.flash, :error) == "Admin access required."

      session = conn |> fetch_session() |> get_session(:user_return_to)
      assert is_nil(session)
    end
  end

  describe "admin login redirect" do
    setup do
      %{
        admin:
          Accounts.register_user(%{
            email: "admin@test.com",
            password: "passwordpassword",
            name: "Test Admin",
            phone_number: "123-456-7890",
            type: :admin
          })
          |> elem(1)
      }
    end

    test "redirects admin to merchant index page", %{conn: conn, admin: admin} do
      conn =
        post(conn, ~p"/users/log-in", %{
          "user" => %{
            "email" => admin.email,
            "password" => "passwordpassword"
          }
        })

      assert redirected_to(conn) == ~p"/merchants"
    end
  end
end
