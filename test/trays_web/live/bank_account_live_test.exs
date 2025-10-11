defmodule TraysWeb.BankAccountLiveTest do
  use TraysWeb.ConnCase

  import Phoenix.LiveViewTest
  import Trays.BankAccountsFixtures

  @update_attrs %{
    account_number: "some updated account_number",
    transit_number: "some updated transit_number",
    institution_number: "some updated institution_number"
  }
  @invalid_attrs %{account_number: nil, transit_number: nil, institution_number: nil}

  setup :register_and_log_in_user

  defp create_bank_account(_context) do
    bank_account = bank_account_fixture()
    merchant_location = Trays.Repo.preload(bank_account, :merchant_location).merchant_location

    create_attrs = %{
      account_number: "some account_number",
      transit_number: "some transit_number",
      institution_number: "some institution_number",
      merchant_location_id: merchant_location.id
    }

    %{bank_account: bank_account, merchant_location: merchant_location, create_attrs: create_attrs}
  end

  describe "Index" do
    setup [:create_bank_account]

    test "lists all bank_accounts", %{
      conn: conn,
      bank_account: bank_account,
      merchant_location: merchant_location
    } do
      {:ok, _index_live, html} =
        live(conn, ~p"/merchant_locations/#{merchant_location}/bank_accounts")

      assert html =~ "Listing Bank accounts"
      assert html =~ bank_account.account_number
    end

    test "saves new bank_account", %{
      conn: conn,
      merchant_location: merchant_location,
      create_attrs: create_attrs
    } do
      {:ok, index_live, _html} =
        live(conn, ~p"/merchant_locations/#{merchant_location}/bank_accounts")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Bank account")
               |> render_click()
               |> follow_redirect(
                 conn,
                 ~p"/merchant_locations/#{merchant_location}/bank_accounts/new"
               )

      assert render(form_live) =~ "New Bank account"

      assert form_live
             |> form("#bank_account-form", bank_account: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#bank_account-form", bank_account: create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/merchant_locations/#{merchant_location}/bank_accounts")

      html = render(index_live)
      assert html =~ "Bank account created successfully"
      assert html =~ "some account_number"
    end

    test "updates bank_account in listing", %{
      conn: conn,
      bank_account: bank_account,
      merchant_location: merchant_location
    } do
      {:ok, index_live, _html} =
        live(conn, ~p"/merchant_locations/#{merchant_location}/bank_accounts")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#bank_accounts-#{bank_account.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/bank_accounts/#{bank_account}/edit")

      assert render(form_live) =~ "Edit Bank account"

      assert form_live
             |> form("#bank_account-form", bank_account: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#bank_account-form", bank_account: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/merchant_locations/#{merchant_location}/bank_accounts")

      html = render(index_live)
      assert html =~ "Bank account updated successfully"
      assert html =~ "some updated account_number"
    end

    test "deletes bank_account in listing", %{
      conn: conn,
      bank_account: bank_account,
      merchant_location: merchant_location
    } do
      {:ok, index_live, _html} =
        live(conn, ~p"/merchant_locations/#{merchant_location}/bank_accounts")

      assert index_live
             |> element("#bank_accounts-#{bank_account.id} a", "Delete")
             |> render_click()

      refute has_element?(index_live, "#bank_accounts-#{bank_account.id}")
    end
  end

  describe "Show" do
    setup [:create_bank_account]

    test "displays bank_account", %{conn: conn, bank_account: bank_account} do
      {:ok, _show_live, html} = live(conn, ~p"/bank_accounts/#{bank_account}")

      assert html =~ "Show Bank account"
      assert html =~ bank_account.account_number
    end

    test "updates bank_account and returns to show", %{conn: conn, bank_account: bank_account} do
      {:ok, show_live, _html} = live(conn, ~p"/bank_accounts/#{bank_account}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/bank_accounts/#{bank_account}/edit?return_to=show")

      assert render(form_live) =~ "Edit Bank account"

      assert form_live
             |> form("#bank_account-form", bank_account: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#bank_account-form", bank_account: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/bank_accounts/#{bank_account}")

      html = render(show_live)
      assert html =~ "Bank account updated successfully"
      assert html =~ "some updated account_number"
    end
  end
end
