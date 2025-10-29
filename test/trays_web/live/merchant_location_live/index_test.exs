defmodule TraysWeb.MerchantLocationLive.IndexTest do
  use TraysWeb.ConnCase

  import Phoenix.LiveViewTest
  import Trays.MerchantLocationsFixtures

  setup do
    user = Trays.AccountsFixtures.user_fixture(%{type: :store_manager})
    conn = Phoenix.ConnTest.build_conn()
    %{conn: TraysWeb.ConnCase.log_in_user(conn, user), user: user}
  end

  describe "Index page" do
    test "renders empty state when user has no locations", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/merchant_locations")

      assert html =~ "My Locations"
      assert html =~ "No locations yet"
      assert html =~ "No locations have been added yet"
    end

    test "displays location count when user has locations", %{conn: conn, user: user} do
      merchant = Trays.Merchants.get_or_create_default_merchant(user.id)
      merchant_location_fixture(%{user: user, merchant: merchant})
      merchant_location_fixture(%{user: user, merchant: merchant})

      {:ok, _index_live, html} = live(conn, ~p"/merchant_locations")

      assert html =~ "My Locations"
      assert html =~ "Total Locations"
      assert html =~ "2"
    end

    test "lists all merchant_locations for the current user", %{conn: conn, user: user} do
      merchant = Trays.Merchants.get_or_create_default_merchant(user.id)
      location1 = merchant_location_fixture(%{user: user, merchant: merchant})
      location2 = merchant_location_fixture(%{user: user, merchant: merchant})

      {:ok, _index_live, html} = live(conn, ~p"/merchant_locations")

      assert html =~ location1.street1
      assert html =~ location1.city
      assert html =~ location2.street1
      assert html =~ location2.city
    end

    test "shows locations for the user's merchant", %{conn: conn, user: user} do
      merchant = Trays.Merchants.get_or_create_default_merchant(user.id)
      location = merchant_location_fixture(%{user: user, merchant: merchant})

      {:ok, _index_live, html} = live(conn, ~p"/merchant_locations")

      assert html =~ location.street1
      assert html =~ location.city
    end

    test "displays location details including street2 when present", %{conn: conn, user: user} do
      _location =
        merchant_location_fixture(%{
          user: user,
          street1: "123 Main St",
          street2: "Suite 200"
        })

      {:ok, _index_live, html} = live(conn, ~p"/merchant_locations")

      assert html =~ "123 Main St"
      assert html =~ "Suite 200"
    end

    test "displays province and postal code together", %{conn: conn, user: user} do
      _location =
        merchant_location_fixture(%{
          user: user,
          province: "ON",
          postal_code: "M5V 3A8"
        })

      {:ok, _index_live, html} = live(conn, ~p"/merchant_locations")

      assert html =~ "ON M5V 3A8"
    end
  end

  describe "Authorization" do
    test "requires merchant authentication", %{} do
      # Log out user
      conn = Phoenix.ConnTest.build_conn()

      {:error, {:redirect, %{to: path}}} = live(conn, ~p"/merchant_locations")

      assert path == ~p"/users/log-in"
    end

    test "requires merchant role", %{} do
      # Customer user should not have access
      customer = Trays.AccountsFixtures.user_fixture(%{type: :customer})

      conn =
        Phoenix.ConnTest.build_conn()
        |> TraysWeb.ConnCase.log_in_user(customer)

      {:error, {:redirect, %{to: path}}} = live(conn, ~p"/merchant_locations")

      assert path == ~p"/"
    end
  end
end
