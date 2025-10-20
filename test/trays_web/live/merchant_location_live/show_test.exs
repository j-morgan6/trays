defmodule TraysWeb.MerchantLocationLive.ShowTest do
  use TraysWeb.ConnCase

  import Phoenix.LiveViewTest
  import Trays.MerchantLocationsFixtures
  import Trays.BankAccountsFixtures

  setup do
    user = Trays.AccountsFixtures.user_fixture(%{type: :merchant})
    conn = Phoenix.ConnTest.build_conn()
    %{conn: TraysWeb.ConnCase.log_in_user(conn, user), user: user}
  end

  describe "Show page" do
    test "displays merchant location details", %{conn: conn, user: user} do
      merchant_location = merchant_location_fixture(%{user: user})
      merchant_location = Trays.Repo.preload(merchant_location, :merchant)

      {:ok, _show_live, html} = live(conn, ~p"/merchant_locations/#{merchant_location}")

      assert html =~ "Location Details"
      assert html =~ merchant_location.street1
      assert html =~ merchant_location.city
      assert html =~ merchant_location.province
      assert html =~ merchant_location.postal_code
      assert html =~ merchant_location.country
    end

    test "displays merchant name in header", %{conn: conn, user: user} do
      merchant_location = merchant_location_fixture(%{user: user})
      merchant_location = Trays.Repo.preload(merchant_location, :merchant)

      {:ok, _show_live, html} = live(conn, ~p"/merchant_locations/#{merchant_location}")

      assert html =~ merchant_location.merchant.name
    end

    test "displays street2 when present", %{conn: conn, user: user} do
      merchant_location =
        merchant_location_fixture(%{user: user, street2: "Apartment 5B"})

      {:ok, _show_live, html} = live(conn, ~p"/merchant_locations/#{merchant_location}")

      assert html =~ "Apartment 5B"
    end

    test "shows edit location button", %{conn: conn, user: user} do
      merchant_location = merchant_location_fixture(%{user: user})

      {:ok, _show_live, html} = live(conn, ~p"/merchant_locations/#{merchant_location}")

      assert html =~ "Edit Location"
      assert html =~ ~p"/merchant_locations/#{merchant_location}/edit"
    end

    test "shows back to merchant link", %{conn: conn, user: user} do
      merchant_location = merchant_location_fixture(%{user: user})
      merchant_location = Trays.Repo.preload(merchant_location, :merchant)

      {:ok, _show_live, html} = live(conn, ~p"/merchant_locations/#{merchant_location}")

      assert html =~ "Back to"
      assert html =~ ~p"/merchants/#{merchant_location.merchant}"
    end
  end

  describe "Location manager display" do
    test "displays manager information when manager is assigned", %{conn: conn, user: user} do
      merchant_location = merchant_location_fixture(%{user: user})

      {:ok, _show_live, html} = live(conn, ~p"/merchant_locations/#{merchant_location}")

      assert html =~ "Location Manager"
      assert html =~ user.email
    end
  end

  describe "Bank account display" do
    test "displays bank account information when present", %{conn: conn, user: user} do
      merchant_location = merchant_location_fixture(%{user: user})

      bank_account =
        bank_account_fixture(%{
          merchant_location: merchant_location,
          account_number: "123456789",
          transit_number: "12345",
          institution_number: "001"
        })

      {:ok, _show_live, html} = live(conn, ~p"/merchant_locations/#{merchant_location}")

      assert html =~ "Bank Account Information"
      assert html =~ bank_account.account_number
      assert html =~ bank_account.transit_number
      assert html =~ bank_account.institution_number
    end

    test "shows edit and delete buttons when bank account exists", %{conn: conn, user: user} do
      merchant_location = merchant_location_fixture(%{user: user})
      bank_account = bank_account_fixture(%{merchant_location: merchant_location})

      {:ok, _show_live, html} = live(conn, ~p"/merchant_locations/#{merchant_location}")

      assert html =~ ~p"/bank_accounts/#{bank_account}/edit"
      assert html =~ "Edit"
      assert html =~ "Delete"
    end

    test "shows add bank account prompt when no bank account exists", %{conn: conn, user: user} do
      merchant_location = merchant_location_fixture(%{user: user})

      {:ok, _show_live, html} = live(conn, ~p"/merchant_locations/#{merchant_location}")

      assert html =~ "No bank account"
      assert html =~ "Add a bank account to receive payments for this location"
      assert html =~ "Add Bank Account"
      assert html =~ ~p"/merchant_locations/#{merchant_location}/bank_accounts/new"
    end
  end

  describe "Bank account deletion" do
    test "deletes bank account and updates page", %{conn: conn, user: user} do
      merchant_location = merchant_location_fixture(%{user: user})
      bank_account = bank_account_fixture(%{merchant_location: merchant_location})

      {:ok, show_live, html} = live(conn, ~p"/merchant_locations/#{merchant_location}")

      assert html =~ bank_account.account_number

      html =
        show_live
        |> element("a", "Delete")
        |> render_click()

      assert html =~ "Bank account deleted successfully"
      assert html =~ "No bank account"
      refute html =~ bank_account.account_number
    end
  end

  describe "Additional information section" do
    test "displays additional information placeholder", %{conn: conn, user: user} do
      merchant_location = merchant_location_fixture(%{user: user})

      {:ok, _show_live, html} = live(conn, ~p"/merchant_locations/#{merchant_location}")

      assert html =~ "Additional Information"
      assert html =~ "More details coming soon"
    end
  end

  describe "Authorization" do
    test "only allows access to merchant location owner", %{conn: conn} do
      other_user = Trays.AccountsFixtures.user_fixture(%{type: :merchant})
      merchant_location = merchant_location_fixture(%{user: other_user})

      assert_raise Ecto.NoResultsError, fn ->
        live(conn, ~p"/merchant_locations/#{merchant_location}")
      end
    end

    test "allows access to merchant owner", %{conn: conn, user: user} do
      merchant = Trays.MerchantsFixtures.merchant_fixture(%{user: user})
      other_user = Trays.AccountsFixtures.user_fixture(%{type: :store_manager})

      merchant_location =
        merchant_location_fixture(%{
          user: other_user,
          merchant: merchant
        })

      {:ok, _show_live, html} = live(conn, ~p"/merchant_locations/#{merchant_location}")

      assert html =~ "Location Details"
    end
  end

  describe "Contact information display" do
    test "displays email when present", %{conn: conn, user: user} do
      merchant_location =
        merchant_location_fixture(%{
          user: user,
          email: "location@example.com"
        })

      {:ok, _show_live, html} = live(conn, ~p"/merchant_locations/#{merchant_location}")

      assert html =~ "location@example.com"
    end

    test "displays phone number when present", %{conn: conn, user: user} do
      merchant_location =
        merchant_location_fixture(%{
          user: user,
          phone_number: "416-555-1234"
        })

      {:ok, _show_live, html} = live(conn, ~p"/merchant_locations/#{merchant_location}")

      assert html =~ "416-555-1234"
    end

    test "displays both email and phone when present", %{conn: conn, user: user} do
      merchant_location =
        merchant_location_fixture(%{
          user: user,
          email: "contact@location.com",
          phone_number: "555-0000"
        })

      {:ok, _show_live, html} = live(conn, ~p"/merchant_locations/#{merchant_location}")

      assert html =~ "contact@location.com"
      assert html =~ "555-0000"
    end
  end
end
