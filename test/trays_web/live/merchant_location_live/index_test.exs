defmodule TraysWeb.MerchantLocationLive.IndexTest do
  use TraysWeb.ConnCase

  import Phoenix.LiveViewTest
  import Trays.MerchantLocationsFixtures

  setup do
    user = Trays.AccountsFixtures.user_fixture(%{type: :merchant})
    conn = Phoenix.ConnTest.build_conn()
    %{conn: TraysWeb.ConnCase.log_in_user(conn, user), user: user}
  end

  describe "Index page" do
    test "renders empty state when user has no locations", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/merchant_locations")

      assert html =~ "My Locations"
      assert html =~ "No locations yet"
      assert html =~ "Add your first location to start managing your business"
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

  describe "Navigation" do
    test "has link to add new location", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/merchant_locations")

      assert html =~ "Add Location"
      assert html =~ ~p"/merchant_locations/new"
    end

    test "has link to edit location", %{conn: conn, user: user} do
      location = merchant_location_fixture(%{user: user})

      {:ok, _index_live, html} = live(conn, ~p"/merchant_locations")

      assert html =~ "Edit"
      assert html =~ ~p"/merchant_locations/#{location}/edit"
    end

    test "displays location rows in table", %{conn: conn, user: user} do
      merchant = Trays.Merchants.get_or_create_default_merchant(user.id)
      location = merchant_location_fixture(%{user: user, merchant: merchant})

      {:ok, _index_live, html} = live(conn, ~p"/merchant_locations")

      # Verify location data is in table
      assert html =~ location.street1
      assert html =~ ~p"/merchant_locations/#{location}"
    end
  end

  describe "Delete location" do
    test "has delete button for each location", %{conn: conn, user: user} do
      merchant = Trays.Merchants.get_or_create_default_merchant(user.id)
      _location = merchant_location_fixture(%{user: user, merchant: merchant})

      {:ok, _index_live, html} = live(conn, ~p"/merchant_locations")

      assert html =~ "Delete"
      assert html =~ "Are you sure you want to delete this location?"
    end

    test "successfully deletes a location", %{conn: conn, user: user} do
      merchant = Trays.Merchants.get_or_create_default_merchant(user.id)
      _location = merchant_location_fixture(%{user: user, merchant: merchant})

      {:ok, index_live, _html} = live(conn, ~p"/merchant_locations")

      # Trigger delete event using the phx-click on the link
      assert index_live
             |> element("a[phx-click*='delete_location']", "Delete")
             |> render_click() =~ "Location deleted successfully"
    end

    test "removes location from stream after deletion", %{conn: conn, user: user} do
      merchant = Trays.Merchants.get_or_create_default_merchant(user.id)
      location = merchant_location_fixture(%{user: user, merchant: merchant})

      {:ok, index_live, html} = live(conn, ~p"/merchant_locations")

      # Verify location is present
      assert html =~ location.street1

      # Delete the location
      index_live
      |> element("a[phx-click*='delete_location']", "Delete")
      |> render_click()

      # Verify location is removed
      html = render(index_live)
      refute html =~ location.street1
    end

    test "decrements location count after deletion", %{conn: conn, user: user} do
      merchant = Trays.Merchants.get_or_create_default_merchant(user.id)
      location1 = merchant_location_fixture(%{user: user, merchant: merchant})
      _location2 = merchant_location_fixture(%{user: user, merchant: merchant})

      {:ok, index_live, html} = live(conn, ~p"/merchant_locations")

      # Verify initial count is 2
      assert html =~ "2"

      # Delete the first location by finding its row specifically
      index_live
      |> element("#locations-#{location1.id} a[phx-click*='delete_location']", "Delete")
      |> render_click()

      # Verify count is now 1
      html = render(index_live)
      assert html =~ "1"
    end

    test "shows empty state after deleting last location", %{conn: conn, user: user} do
      merchant = Trays.Merchants.get_or_create_default_merchant(user.id)
      _location = merchant_location_fixture(%{user: user, merchant: merchant})

      {:ok, index_live, _html} = live(conn, ~p"/merchant_locations")

      # Delete the only location
      index_live
      |> element("a[phx-click*='delete_location']", "Delete")
      |> render_click()

      # Verify empty state is shown
      html = render(index_live)
      assert html =~ "No locations yet"
      assert html =~ "Add your first location to start managing your business"
    end

    test "displays error when deletion fails", %{conn: conn, user: user} do
      merchant = Trays.Merchants.get_or_create_default_merchant(user.id)
      location = merchant_location_fixture(%{user: user, merchant: merchant})

      # Create a bank account to prevent deletion (foreign key constraint)
      {:ok, _bank_account} =
        Trays.BankAccounts.create_bank_account(%{
          merchant_location_id: location.id,
          account_number: "1234567890",
          transit_number: "12345",
          institution_number: "001",
          account_holder_name: "Test Holder"
        })

      {:ok, index_live, html} = live(conn, ~p"/merchant_locations")

      # Verify location is present
      assert html =~ location.street1

      # Try to delete the location
      index_live
      |> element("a[phx-click*='delete_location']", "Delete")
      |> render_click()

      # Verify error message
      html = render(index_live)
      assert html =~ "Unable to delete location"

      # Verify location is still present
      assert html =~ location.street1
    end

    test "location count does not change when deletion fails", %{conn: conn, user: user} do
      merchant = Trays.Merchants.get_or_create_default_merchant(user.id)
      location = merchant_location_fixture(%{user: user, merchant: merchant})

      # Create a bank account to prevent deletion
      {:ok, _bank_account} =
        Trays.BankAccounts.create_bank_account(%{
          merchant_location_id: location.id,
          account_number: "1234567890",
          transit_number: "12345",
          institution_number: "001",
          account_holder_name: "Test Holder"
        })

      {:ok, index_live, html} = live(conn, ~p"/merchant_locations")

      # Verify initial count is 1
      assert html =~ "1"

      # Try to delete the location
      index_live
      |> element("a[phx-click*='delete_location']", "Delete")
      |> render_click()

      # Verify count is still 1
      html = render(index_live)
      assert html =~ "1"
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
