defmodule TraysWeb.MerchantLive.IndexTest do
  use TraysWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Trays.AccountsFixtures
  import Trays.MerchantsFixtures
  import Trays.MerchantLocationsFixtures

  describe "Merchant Index - Mount" do
    test "requires authentication", %{conn: conn} do
      assert {:error, {:redirect, %{to: "/users/log-in"}}} = live(conn, ~p"/merchants")
    end

    test "mounts successfully for authenticated merchant user", %{conn: conn} do
      user = user_fixture(%{type: :merchant})
      conn = log_in_user(conn, user)

      assert {:ok, _view, html} = live(conn, ~p"/merchants")
      assert html =~ "My Business"
    end

    test "creates default merchant if user has none", %{conn: conn} do
      user = user_fixture(%{type: :merchant})
      conn = log_in_user(conn, user)

      assert {:ok, _view, html} = live(conn, ~p"/merchants")
      assert html =~ "My Business"
      assert html =~ "Manage your business and locations"

      # Verify merchant was created in database
      merchants = Trays.Merchants.list_merchants(user.id)
      assert length(merchants) == 1
      assert hd(merchants).name == "My Business"
    end

    test "shows existing merchant if user already has one", %{conn: conn} do
      user = user_fixture(%{type: :merchant})

      merchant =
        merchant_fixture(%{user: user, name: "Existing Business", description: "My description"})

      conn = log_in_user(conn, user)

      assert {:ok, _view, html} = live(conn, ~p"/merchants")
      assert html =~ "Existing Business"
      assert html =~ "My description"
      refute html =~ "My Business"
    end

    test "shows the user's single merchant", %{conn: conn} do
      user = user_fixture(%{type: :merchant})
      _merchant = merchant_fixture(%{user: user, name: "Single Business"})
      conn = log_in_user(conn, user)

      assert {:ok, _view, html} = live(conn, ~p"/merchants")
      assert html =~ "Single Business"
    end
  end

  describe "Merchant Index - Display" do
    test "displays merchant name and description", %{conn: conn} do
      user = user_fixture(%{type: :merchant})

      _merchant =
        merchant_fixture(%{user: user, name: "Test Restaurant", description: "Best food in town"})

      conn = log_in_user(conn, user)

      assert {:ok, _view, html} = live(conn, ~p"/merchants")
      assert html =~ "Test Restaurant"
      assert html =~ "Best food in town"
    end

    test "displays location count when merchant has no locations", %{conn: conn} do
      user = user_fixture(%{type: :merchant})
      _merchant = merchant_fixture(%{user: user})
      conn = log_in_user(conn, user)

      assert {:ok, _view, html} = live(conn, ~p"/merchants")
      assert html =~ "Total Locations"
      assert html =~ ">0<"
    end

    test "displays correct location count when merchant has locations", %{conn: conn} do
      user = user_fixture(%{type: :merchant})
      merchant = merchant_fixture(%{user: user})
      merchant_location_fixture(%{user: user, merchant: merchant})
      merchant_location_fixture(%{user: user, merchant: merchant, city: "Vancouver"})
      merchant_location_fixture(%{user: user, merchant: merchant, city: "Montreal"})
      conn = log_in_user(conn, user)

      assert {:ok, _view, html} = live(conn, ~p"/merchants")
      assert html =~ "Total Locations"
      assert html =~ ">3<"
    end

    test "shows empty state when no locations exist", %{conn: conn} do
      user = user_fixture(%{type: :merchant})
      _merchant = merchant_fixture(%{user: user})
      conn = log_in_user(conn, user)

      assert {:ok, _view, html} = live(conn, ~p"/merchants")
      assert html =~ "No locations yet"
      assert html =~ "Add your first location to start managing this business"
    end

    test "shows locations table when locations exist", %{conn: conn} do
      user = user_fixture(%{type: :merchant})
      merchant = merchant_fixture(%{user: user})

      _location =
        merchant_location_fixture(%{
          user: user,
          merchant: merchant,
          street1: "123 Main St",
          city: "Toronto",
          province: "ON"
        })

      conn = log_in_user(conn, user)

      assert {:ok, _view, html} = live(conn, ~p"/merchants")
      assert html =~ "123 Main St"
      assert html =~ "Toronto"
      assert html =~ "ON"
      refute html =~ "No locations yet"
    end

    test "displays all locations for the merchant", %{conn: conn} do
      user = user_fixture(%{type: :merchant})
      merchant = merchant_fixture(%{user: user})

      _location1 =
        merchant_location_fixture(%{
          user: user,
          merchant: merchant,
          street1: "123 Main St",
          city: "Toronto"
        })

      _location2 =
        merchant_location_fixture(%{
          user: user,
          merchant: merchant,
          street1: "456 Queen St",
          city: "Vancouver"
        })

      _location3 =
        merchant_location_fixture(%{
          user: user,
          merchant: merchant,
          street1: "789 King St",
          city: "Montreal"
        })

      conn = log_in_user(conn, user)

      assert {:ok, _view, html} = live(conn, ~p"/merchants")
      assert html =~ "123 Main St"
      assert html =~ "456 Queen St"
      assert html =~ "789 King St"
      assert html =~ "Toronto"
      assert html =~ "Vancouver"
      assert html =~ "Montreal"
    end

    test "shows street2 when present", %{conn: conn} do
      user = user_fixture(%{type: :merchant})
      merchant = merchant_fixture(%{user: user})

      _location =
        merchant_location_fixture(%{
          user: user,
          merchant: merchant,
          street1: "123 Main St",
          street2: "Unit 4",
          city: "Toronto"
        })

      conn = log_in_user(conn, user)

      assert {:ok, _view, html} = live(conn, ~p"/merchants")
      assert html =~ "123 Main St"
      assert html =~ "Unit 4"
    end
  end

  describe "Merchant Index - Navigation" do
    test "shows edit merchant link", %{conn: conn} do
      user = user_fixture(%{type: :merchant})
      merchant = merchant_fixture(%{user: user})
      conn = log_in_user(conn, user)

      assert {:ok, _view, html} = live(conn, ~p"/merchants")
      assert html =~ "href=\"/merchants/#{merchant.id}/edit"
      assert html =~ "Edit"
    end

    test "shows add location link with merchant_id", %{conn: conn} do
      user = user_fixture(%{type: :merchant})
      merchant = merchant_fixture(%{user: user})
      conn = log_in_user(conn, user)

      assert {:ok, _view, html} = live(conn, ~p"/merchants")
      assert html =~ "href=\"/merchant_locations/new?merchant_id=#{merchant.id}\""
      assert html =~ "Add Location"
    end

    test "location rows are clickable", %{conn: conn} do
      user = user_fixture(%{type: :merchant})
      merchant = merchant_fixture(%{user: user})
      location = merchant_location_fixture(%{user: user, merchant: merchant})
      conn = log_in_user(conn, user)

      assert {:ok, _view, html} = live(conn, ~p"/merchants")
      assert html =~ "phx-click"
      assert html =~ "/merchant_locations/#{location.id}"
    end
  end

  describe "Merchant Index - Authorization" do
    test "user only sees their own merchant", %{conn: conn} do
      user1 = user_fixture(%{type: :merchant})
      user2 = user_fixture(%{email: "other@example.com", type: :merchant})
      _merchant1 = merchant_fixture(%{user: user1, name: "User1 Merchant"})
      _merchant2 = merchant_fixture(%{user: user2, name: "User2 Merchant"})
      conn = log_in_user(conn, user1)

      assert {:ok, _view, html} = live(conn, ~p"/merchants")
      assert html =~ "User1 Merchant"
      refute html =~ "User2 Merchant"
    end

    test "user only sees locations from their merchant", %{conn: conn} do
      user1 = user_fixture(%{type: :merchant})
      user2 = user_fixture(%{email: "other@example.com", type: :merchant})
      merchant1 = merchant_fixture(%{user: user1})
      merchant2 = merchant_fixture(%{user: user2})

      _location1 =
        merchant_location_fixture(%{user: user1, merchant: merchant1, street1: "User1 Street"})

      _location2 =
        merchant_location_fixture(%{user: user2, merchant: merchant2, street1: "User2 Street"})

      conn = log_in_user(conn, user1)

      assert {:ok, _view, html} = live(conn, ~p"/merchants")
      assert html =~ "User1 Street"
      refute html =~ "User2 Street"
    end
  end
end
