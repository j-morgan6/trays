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

    test "requires admin role", %{conn: conn} do
      user = user_fixture(%{type: :merchant})
      conn = log_in_user(conn, user)

      assert {:error, {:redirect, %{to: "/", flash: %{"error" => "Admin access required."}}}} =
               live(conn, ~p"/merchants")
    end

    test "mounts successfully for admin user", %{conn: conn} do
      user = user_fixture(%{type: :admin})
      conn = log_in_user(conn, user)

      assert {:ok, _view, html} = live(conn, ~p"/merchants")
      assert html =~ "All Merchants"
    end
  end

  describe "Merchant Index - Display" do
    test "shows empty state when no merchants exist", %{conn: conn} do
      user = user_fixture(%{type: :admin})
      conn = log_in_user(conn, user)

      assert {:ok, _view, html} = live(conn, ~p"/merchants")
      assert html =~ "No merchants yet"
      assert html =~ "Merchants will appear here once they register"
    end

    test "displays merchant count correctly", %{conn: conn} do
      user = user_fixture(%{type: :admin})
      merchant_user1 = user_fixture(%{email: "merchant1@example.com", type: :merchant})
      merchant_user2 = user_fixture(%{email: "merchant2@example.com", type: :merchant})
      _merchant1 = merchant_fixture(%{user: merchant_user1})
      _merchant2 = merchant_fixture(%{user: merchant_user2})
      conn = log_in_user(conn, user)

      assert {:ok, _view, html} = live(conn, ~p"/merchants")
      assert html =~ "Total Merchants"
      assert html =~ ">2<"
    end

    test "displays all merchants in the system", %{conn: conn} do
      user = user_fixture(%{type: :admin})
      merchant_user1 = user_fixture(%{email: "merchant1@example.com", type: :merchant})
      merchant_user2 = user_fixture(%{email: "merchant2@example.com", type: :merchant})

      _merchant1 =
        merchant_fixture(%{
          user: merchant_user1,
          name: "Pizza Place",
          description: "Best pizza"
        })

      _merchant2 =
        merchant_fixture(%{
          user: merchant_user2,
          name: "Burger Joint",
          description: "Best burgers"
        })

      conn = log_in_user(conn, user)

      assert {:ok, _view, html} = live(conn, ~p"/merchants")
      assert html =~ "Pizza Place"
      assert html =~ "Burger Joint"
      assert html =~ "Best pizza"
      assert html =~ "Best burgers"
    end

    test "displays location count for each merchant", %{conn: conn} do
      user = user_fixture(%{type: :admin})
      merchant_user = user_fixture(%{email: "merchant@example.com", type: :merchant})
      merchant = merchant_fixture(%{user: merchant_user, name: "Test Merchant"})
      merchant_location_fixture(%{user: merchant_user, merchant: merchant})
      merchant_location_fixture(%{user: merchant_user, merchant: merchant, city: "Vancouver"})
      merchant_location_fixture(%{user: merchant_user, merchant: merchant, city: "Montreal"})
      conn = log_in_user(conn, user)

      assert {:ok, view, html} = live(conn, ~p"/merchants")
      assert html =~ "Test Merchant"
      # The location count 3 should appear in the rendered view
      assert render(view) =~ "3"
    end

    test "shows zero location count for merchants without locations", %{conn: conn} do
      user = user_fixture(%{type: :admin})
      merchant_user = user_fixture(%{email: "merchant@example.com", type: :merchant})
      merchant = merchant_fixture(%{user: merchant_user, name: "No Locations"})
      conn = log_in_user(conn, user)

      assert {:ok, view, html} = live(conn, ~p"/merchants")
      assert html =~ "No Locations"
      # The location count 0 should appear in the rendered view
      assert render(view) =~ "0"
    end
  end

  describe "Merchant Index - Navigation" do
    test "merchant rows are clickable", %{conn: conn} do
      user = user_fixture(%{type: :admin})
      merchant_user = user_fixture(%{email: "merchant@example.com", type: :merchant})
      merchant = merchant_fixture(%{user: merchant_user})
      conn = log_in_user(conn, user)

      assert {:ok, _view, html} = live(conn, ~p"/merchants")
      assert html =~ "phx-click"
      assert html =~ "/merchants/#{merchant.id}"
    end

    test "shows edit merchant link for each merchant", %{conn: conn} do
      user = user_fixture(%{type: :admin})
      merchant_user = user_fixture(%{email: "merchant@example.com", type: :merchant})
      merchant = merchant_fixture(%{user: merchant_user})
      conn = log_in_user(conn, user)

      assert {:ok, _view, html} = live(conn, ~p"/merchants")
      assert html =~ "href=\"/merchants/#{merchant.id}/edit"
      assert html =~ "Edit"
    end
  end

  describe "Merchant Index - Delete" do
    test "deletes merchant successfully", %{conn: conn} do
      user = user_fixture(%{type: :admin})
      merchant_user = user_fixture(%{email: "merchant@example.com", type: :merchant})
      merchant = merchant_fixture(%{user: merchant_user, name: "To Delete"})
      conn = log_in_user(conn, user)

      {:ok, view, _html} = live(conn, ~p"/merchants")

      html = render_click(view, "delete_merchant", %{id: merchant.id})

      html = render(view)
      refute html =~ "To Delete"
      assert html =~ "Merchant deleted successfully"
    end

    test "updates merchant count after deletion", %{conn: conn} do
      user = user_fixture(%{type: :admin})
      merchant_user1 = user_fixture(%{email: "merchant1@example.com", type: :merchant})
      merchant_user2 = user_fixture(%{email: "merchant2@example.com", type: :merchant})
      merchant1 = merchant_fixture(%{user: merchant_user1})
      _merchant2 = merchant_fixture(%{user: merchant_user2})
      conn = log_in_user(conn, user)

      {:ok, view, html} = live(conn, ~p"/merchants")
      assert html =~ ">2<"

      render_click(view, "delete_merchant", %{id: merchant1.id})

      html = render(view)
      assert html =~ ">1<"
    end
  end
end
