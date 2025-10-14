defmodule TraysWeb.MerchantLive.ShowTest do
  use TraysWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Trays.AccountsFixtures
  import Trays.MerchantsFixtures
  import Trays.MerchantLocationsFixtures

  describe "Merchant Show - Mount" do
    test "requires authentication", %{conn: conn} do
      user = user_fixture(%{type: :merchant})
      merchant = merchant_fixture(%{user: user})

      assert {:error, {:redirect, %{to: "/users/log-in"}}} =
               live(conn, ~p"/merchants/#{merchant}")
    end

    test "requires merchant role", %{conn: conn} do
      user = user_fixture(%{type: :customer})
      merchant_user = user_fixture(%{email: "merchant@example.com", type: :merchant})
      merchant = merchant_fixture(%{user: merchant_user})
      conn = log_in_user(conn, user)

      assert {:error, {:redirect, %{to: "/", flash: %{"error" => "Merchant access required."}}}} =
               live(conn, ~p"/merchants/#{merchant}")
    end

    test "mounts successfully for merchant viewing their own store", %{conn: conn} do
      user = user_fixture(%{type: :merchant})
      merchant = merchant_fixture(%{user: user, name: "My Store"})
      conn = log_in_user(conn, user)

      assert {:ok, _view, html} = live(conn, ~p"/merchants/#{merchant}")
      assert html =~ "My Store"
    end

    test "merchant cannot view another merchant's store", %{conn: conn} do
      user1 = user_fixture(%{type: :merchant})
      user2 = user_fixture(%{email: "other@example.com", type: :merchant})
      merchant2 = merchant_fixture(%{user: user2})
      conn = log_in_user(conn, user1)

      assert_raise Ecto.NoResultsError, fn ->
        live(conn, ~p"/merchants/#{merchant2}")
      end
    end
  end

  describe "Merchant Show - Display" do
    test "displays merchant name and description", %{conn: conn} do
      user = user_fixture(%{type: :merchant})

      merchant =
        merchant_fixture(%{user: user, name: "Test Restaurant", description: "Best food in town"})

      conn = log_in_user(conn, user)

      assert {:ok, _view, html} = live(conn, ~p"/merchants/#{merchant}")
      assert html =~ "Test Restaurant"
      assert html =~ "Best food in town"
    end

    test "displays location count when merchant has no locations", %{conn: conn} do
      user = user_fixture(%{type: :merchant})
      merchant = merchant_fixture(%{user: user})
      conn = log_in_user(conn, user)

      assert {:ok, _view, html} = live(conn, ~p"/merchants/#{merchant}")
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

      assert {:ok, _view, html} = live(conn, ~p"/merchants/#{merchant}")
      assert html =~ "Total Locations"
      assert html =~ ">3<"
    end

    test "shows empty state when no locations exist", %{conn: conn} do
      user = user_fixture(%{type: :merchant})
      merchant = merchant_fixture(%{user: user})
      conn = log_in_user(conn, user)

      assert {:ok, _view, html} = live(conn, ~p"/merchants/#{merchant}")
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

      assert {:ok, _view, html} = live(conn, ~p"/merchants/#{merchant}")
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

      assert {:ok, _view, html} = live(conn, ~p"/merchants/#{merchant}")
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

      assert {:ok, _view, html} = live(conn, ~p"/merchants/#{merchant}")
      assert html =~ "123 Main St"
      assert html =~ "Unit 4"
    end
  end

  describe "Merchant Show - Navigation" do
    test "shows edit merchant link", %{conn: conn} do
      user = user_fixture(%{type: :merchant})
      merchant = merchant_fixture(%{user: user})
      conn = log_in_user(conn, user)

      assert {:ok, _view, html} = live(conn, ~p"/merchants/#{merchant}")
      assert html =~ "href=\"/merchants/#{merchant.id}/edit"
      assert html =~ "Edit"
    end

    test "shows add location link with merchant_id", %{conn: conn} do
      user = user_fixture(%{type: :merchant})
      merchant = merchant_fixture(%{user: user})
      conn = log_in_user(conn, user)

      assert {:ok, _view, html} = live(conn, ~p"/merchants/#{merchant}")
      assert html =~ "href=\"/merchant_locations/new?merchant_id=#{merchant.id}\""
      assert html =~ "Add Location"
    end

    test "location rows are clickable", %{conn: conn} do
      user = user_fixture(%{type: :merchant})
      merchant = merchant_fixture(%{user: user})
      location = merchant_location_fixture(%{user: user, merchant: merchant})
      conn = log_in_user(conn, user)

      assert {:ok, _view, html} = live(conn, ~p"/merchants/#{merchant}")
      assert html =~ "phx-click"
      assert html =~ "/merchant_locations/#{location.id}"
    end
  end

  describe "Merchant Show - Delete Location" do
    test "deletes location successfully", %{conn: conn} do
      user = user_fixture(%{type: :merchant})
      merchant = merchant_fixture(%{user: user})

      location =
        merchant_location_fixture(%{
          user: user,
          merchant: merchant,
          street1: "123 Main St"
        })

      conn = log_in_user(conn, user)

      {:ok, view, _html} = live(conn, ~p"/merchants/#{merchant}")

      html = render_click(view, "delete_location", %{id: location.id})

      html = render(view)
      refute html =~ "123 Main St"
      assert html =~ "Location deleted successfully"
    end

    test "updates location count after deletion", %{conn: conn} do
      user = user_fixture(%{type: :merchant})
      merchant = merchant_fixture(%{user: user})
      location1 = merchant_location_fixture(%{user: user, merchant: merchant})
      _location2 = merchant_location_fixture(%{user: user, merchant: merchant, city: "Vancouver"})
      conn = log_in_user(conn, user)

      {:ok, view, html} = live(conn, ~p"/merchants/#{merchant}")
      assert html =~ ">2<"

      render_click(view, "delete_location", %{id: location1.id})

      html = render(view)
      assert html =~ ">1<"
    end
  end
end
