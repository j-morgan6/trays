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

  setup do
    user = Trays.AccountsFixtures.user_fixture(%{type: :merchant})
    conn = Phoenix.ConnTest.build_conn()
    %{conn: TraysWeb.ConnCase.log_in_user(conn, user), user: user}
  end

  defp create_bank_account(%{user: user}) do
    merchant_location = Trays.MerchantLocationsFixtures.merchant_location_fixture(%{user: user})
    bank_account = bank_account_fixture(%{merchant_location: merchant_location})
    merchant_location = Trays.Repo.preload(merchant_location, :merchant)

    create_attrs = %{
      account_number: "some account_number",
      transit_number: "some transit_number",
      institution_number: "some institution_number",
      merchant_location_id: merchant_location.id
    }

    %{
      bank_account: bank_account,
      merchant_location: merchant_location,
      merchant: merchant_location.merchant,
      create_attrs: create_attrs
    }
  end

  describe "Form validation and error handling" do
    setup [:create_bank_account]

    test "validates bank_account on input change", %{
      conn: conn,
      merchant_location: merchant_location
    } do
      {:ok, form_live, _html} =
        live(conn, ~p"/merchant_locations/#{merchant_location}/bank_accounts/new")

      assert form_live
             |> form("#bank_account-form", bank_account: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"
    end

    test "handles validation errors when creating bank_account", %{
      conn: conn,
      merchant_location: merchant_location
    } do
      {:ok, form_live, _html} =
        live(conn, ~p"/merchant_locations/#{merchant_location}/bank_accounts/new")

      html =
        form_live
        |> form("#bank_account-form", bank_account: @invalid_attrs)
        |> render_submit()

      assert html =~ "can&#39;t be blank"
      assert html =~ "New Bank account"
    end

    test "handles validation errors when updating bank_account", %{
      conn: conn,
      bank_account: bank_account
    } do
      {:ok, form_live, _html} = live(conn, ~p"/bank_accounts/#{bank_account}/edit")

      html =
        form_live
        |> form("#bank_account-form", bank_account: @invalid_attrs)
        |> render_submit()

      assert html =~ "can&#39;t be blank"
      assert html =~ "Edit Bank account"
    end
  end

  describe "Return path handling" do
    setup [:create_bank_account]

    test "new form redirects to merchant show page", %{
      conn: conn,
      merchant_location: merchant_location,
      merchant: merchant,
      create_attrs: create_attrs
    } do
      {:ok, form_live, _html} =
        live(conn, ~p"/merchant_locations/#{merchant_location}/bank_accounts/new")

      assert {:ok, show_live, _html} =
               form_live
               |> form("#bank_account-form", bank_account: create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/merchants/#{merchant}")

      assert render(show_live) =~ "Bank account created successfully"
    end

    test "edit form redirects to merchant show page", %{
      conn: conn,
      bank_account: bank_account,
      merchant: merchant
    } do
      {:ok, form_live, _html} = live(conn, ~p"/bank_accounts/#{bank_account}/edit")

      assert {:ok, show_live, _html} =
               form_live
               |> form("#bank_account-form", bank_account: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/merchants/#{merchant}")

      assert render(show_live) =~ "Bank account updated successfully"
    end
  end
end
