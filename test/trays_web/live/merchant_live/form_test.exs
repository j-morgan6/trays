defmodule TraysWeb.MerchantLive.FormTest do
  use TraysWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Trays.AccountsFixtures
  import Trays.MerchantsFixtures

  describe "Merchant Form - Edit - Mount" do
    test "requires authentication", %{conn: conn} do
      assert {:error, {:redirect, %{to: "/users/log-in"}}} = live(conn, ~p"/merchants/123/edit")
    end

    test "mounts successfully for authenticated user with their merchant", %{conn: conn} do
      user = user_fixture(%{type: :merchant})
      merchant = merchant_fixture(%{user: user, name: "Test Business"})
      conn = log_in_user(conn, user)

      assert {:ok, _view, html} = live(conn, ~p"/merchants/#{merchant}/edit")
      assert html =~ "Edit Business"
      assert html =~ "Test Business"
    end

    test "raises when user tries to edit another user's merchant", %{conn: conn} do
      user1 = user_fixture(%{type: :merchant})
      user2 = user_fixture(%{email: "other@example.com", type: :merchant})
      merchant2 = merchant_fixture(%{user: user2})
      conn = log_in_user(conn, user1)

      assert_raise Ecto.NoResultsError, fn ->
        live(conn, ~p"/merchants/#{merchant2}/edit")
      end
    end

    test "displays existing merchant data in form", %{conn: conn} do
      user = user_fixture(%{type: :merchant})

      merchant =
        merchant_fixture(%{user: user, name: "Pizza Palace", description: "Best pizza in town"})

      conn = log_in_user(conn, user)

      assert {:ok, _view, html} = live(conn, ~p"/merchants/#{merchant}/edit")
      assert html =~ "value=\"Pizza Palace\""
      assert html =~ "Best pizza in town"
    end

    test "initializes character counters with existing data", %{conn: conn} do
      user = user_fixture(%{type: :merchant})
      merchant = merchant_fixture(%{user: user, name: "Test", description: "A description"})
      conn = log_in_user(conn, user)

      assert {:ok, _view, html} = live(conn, ~p"/merchants/#{merchant}/edit")
      # "Test" is 4 characters
      assert html =~ "4/100"
      # "A description" is 13 characters
      assert html =~ "13/500"
    end
  end

  describe "Merchant Form - Validation" do
    test "validates form on change", %{conn: conn} do
      user = user_fixture(%{type: :merchant})
      merchant = merchant_fixture(%{user: user})
      conn = log_in_user(conn, user)

      assert {:ok, view, _html} = live(conn, ~p"/merchants/#{merchant}/edit")

      # Clear the name field (invalid)
      html =
        view
        |> form("#merchant-form", merchant: %{name: ""})
        |> render_change()

      assert html =~ "can&#39;t be blank"
    end

    test "updates character counter on input", %{conn: conn} do
      user = user_fixture(%{type: :merchant})
      merchant = merchant_fixture(%{user: user, name: "Test"})
      conn = log_in_user(conn, user)

      assert {:ok, view, html} = live(conn, ~p"/merchants/#{merchant}/edit")
      assert html =~ "4/100"

      html =
        view
        |> form("#merchant-form", merchant: %{name: "New Business Name"})
        |> render_change()

      assert html =~ "17/100"
    end

    test "shows validation error for missing name", %{conn: conn} do
      user = user_fixture(%{type: :merchant})
      merchant = merchant_fixture(%{user: user})
      conn = log_in_user(conn, user)

      assert {:ok, view, _html} = live(conn, ~p"/merchants/#{merchant}/edit")

      html =
        view
        |> form("#merchant-form", merchant: %{name: "", description: "Valid description"})
        |> render_change()

      assert html =~ "can&#39;t be blank"
    end

    test "shows validation error for missing description", %{conn: conn} do
      user = user_fixture(%{type: :merchant})
      merchant = merchant_fixture(%{user: user})
      conn = log_in_user(conn, user)

      assert {:ok, view, _html} = live(conn, ~p"/merchants/#{merchant}/edit")

      html =
        view
        |> form("#merchant-form", merchant: %{name: "Valid Name", description: ""})
        |> render_change()

      assert html =~ "can&#39;t be blank"
    end

    test "disables submit button when form is invalid", %{conn: conn} do
      user = user_fixture(%{type: :merchant})
      merchant = merchant_fixture(%{user: user})
      conn = log_in_user(conn, user)

      assert {:ok, view, _html} = live(conn, ~p"/merchants/#{merchant}/edit")

      html =
        view
        |> form("#merchant-form", merchant: %{name: ""})
        |> render_change()

      assert html =~ "disabled"
      assert html =~ "cursor-not-allowed"
    end
  end

  describe "Merchant Form - Save" do
    test "updates merchant with valid data", %{conn: conn} do
      user = user_fixture(%{type: :merchant})
      merchant = merchant_fixture(%{user: user, name: "Old Name"})
      conn = log_in_user(conn, user)

      assert {:ok, view, _html} = live(conn, ~p"/merchants/#{merchant}/edit")

      assert view
             |> form("#merchant-form",
               merchant: %{name: "Updated Name", description: "Updated description"}
             )
             |> render_submit()

      assert_redirect(view, ~p"/merchants")

      # Verify in database
      updated_merchant = Trays.Merchants.get_merchant!(merchant.id, user.id)
      assert updated_merchant.name == "Updated Name"
      assert updated_merchant.description == "Updated description"
    end

    test "does not update with invalid data", %{conn: conn} do
      user = user_fixture(%{type: :merchant})
      merchant = merchant_fixture(%{user: user, name: "Original"})
      conn = log_in_user(conn, user)

      {:ok, view, _html} = live(conn, ~p"/merchants/#{merchant}/edit")

      html =
        view
        |> form("#merchant-form", merchant: %{name: ""})
        |> render_submit()

      assert html =~ "can&#39;t be blank"

      # Verify not changed in database
      unchanged_merchant = Trays.Merchants.get_merchant!(merchant.id, user.id)
      assert unchanged_merchant.name == "Original"
    end
  end

  describe "Merchant Form - Navigation" do
    test "shows back to dashboard link", %{conn: conn} do
      user = user_fixture(%{type: :merchant})
      merchant = merchant_fixture(%{user: user})
      conn = log_in_user(conn, user)

      assert {:ok, _view, html} = live(conn, ~p"/merchants/#{merchant}/edit")
      assert html =~ "Back to Dashboard"
      assert html =~ "href=\"/merchants\""
    end

    test "cancel button links back to merchants", %{conn: conn} do
      user = user_fixture(%{type: :merchant})
      merchant = merchant_fixture(%{user: user})
      conn = log_in_user(conn, user)

      assert {:ok, _view, html} = live(conn, ~p"/merchants/#{merchant}/edit")
      assert html =~ "Cancel"
      assert html =~ "href=\"/merchants\""
    end
  end

  describe "Merchant Form - Character Limits" do
    test "shows character counter for name over limit", %{conn: conn} do
      user = user_fixture(%{type: :merchant})
      merchant = merchant_fixture(%{user: user})
      conn = log_in_user(conn, user)

      assert {:ok, view, _html} = live(conn, ~p"/merchants/#{merchant}/edit")

      long_name = String.duplicate("a", 101)

      html =
        view
        |> form("#merchant-form", merchant: %{name: long_name})
        |> render_change()

      # Character counter shows over limit (browser maxlength prevents actual save)
      assert html =~ "101/100"
      assert html =~ "text-red-600"
    end

    test "shows character counter for description over limit", %{conn: conn} do
      user = user_fixture(%{type: :merchant})
      merchant = merchant_fixture(%{user: user})
      conn = log_in_user(conn, user)

      assert {:ok, view, _html} = live(conn, ~p"/merchants/#{merchant}/edit")

      long_description = String.duplicate("a", 501)

      html =
        view
        |> form("#merchant-form", merchant: %{description: long_description})
        |> render_change()

      # Character counter shows over limit (browser maxlength prevents actual save)
      assert html =~ "501/500"
      assert html =~ "text-red-600"
    end

    test "shows warning color when approaching character limit", %{conn: conn} do
      user = user_fixture(%{type: :merchant})
      merchant = merchant_fixture(%{user: user})
      conn = log_in_user(conn, user)

      assert {:ok, view, _html} = live(conn, ~p"/merchants/#{merchant}/edit")

      # 90 characters (90% of 100)
      name_90_chars = String.duplicate("a", 90)

      html =
        view
        |> form("#merchant-form", merchant: %{name: name_90_chars})
        |> render_change()

      assert html =~ "90/100"
      assert html =~ "text-amber"
    end
  end

  describe "Merchant Form - UI Elements" do
    test "displays helper text for name field", %{conn: conn} do
      user = user_fixture(%{type: :merchant})
      merchant = merchant_fixture(%{user: user})
      conn = log_in_user(conn, user)

      assert {:ok, _view, html} = live(conn, ~p"/merchants/#{merchant}/edit")
      assert html =~ "This is your main business name displayed throughout the dashboard"
    end

    test "shows placeholder text for inputs", %{conn: conn} do
      user = user_fixture(%{type: :merchant})
      merchant = merchant_fixture(%{user: user})
      conn = log_in_user(conn, user)

      assert {:ok, _view, html} = live(conn, ~p"/merchants/#{merchant}/edit")
      assert html =~ "Pizza Palace"
      assert html =~ "Describe your business"
    end

    test "marks required fields with asterisk", %{conn: conn} do
      user = user_fixture(%{type: :merchant})
      merchant = merchant_fixture(%{user: user})
      conn = log_in_user(conn, user)

      assert {:ok, _view, html} = live(conn, ~p"/merchants/#{merchant}/edit")
      assert html =~ "Business Name"
      assert html =~ "text-red-500"
      assert html =~ "*"
    end
  end
end
