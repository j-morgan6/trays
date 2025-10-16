defmodule TraysWeb.MerchantLocationLiveTest do
  use TraysWeb.ConnCase

  import Phoenix.LiveViewTest
  import Trays.MerchantLocationsFixtures

  @create_attrs %{
    street1: "some street1",
    street2: "some street2",
    city: "some city",
    province: "some province",
    postal_code: "some postal_code",
    country: "some country"
  }
  @update_attrs %{
    street1: "some updated street1",
    street2: "some updated street2",
    city: "some updated city",
    province: "some updated province",
    postal_code: "some updated postal_code",
    country: "some updated country"
  }
  @invalid_attrs %{
    street1: nil,
    street2: nil,
    city: nil,
    province: nil,
    postal_code: nil,
    country: nil
  }

  setup do
    user = Trays.AccountsFixtures.user_fixture(%{type: :merchant})
    conn = Phoenix.ConnTest.build_conn()
    %{conn: TraysWeb.ConnCase.log_in_user(conn, user), user: user}
  end

  defp create_merchant_location(%{user: user}) do
    merchant_location = merchant_location_fixture(%{user: user})
    %{merchant_location: merchant_location}
  end

  describe "Form validation and error handling" do
    setup [:create_merchant_location]

    test "validates merchant_location on input change", %{conn: conn} do
      {:ok, form_live, _html} = live(conn, ~p"/merchant_locations/new")

      assert form_live
             |> form("#merchant_location-form", merchant_location: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      refute form_live
             |> form("#merchant_location-form", merchant_location: @create_attrs)
             |> render_change() =~ "can&#39;t be blank"
    end

    test "handles validation errors when creating merchant_location", %{conn: conn} do
      {:ok, form_live, _html} = live(conn, ~p"/merchant_locations/new")

      html =
        form_live
        |> form("#merchant_location-form", merchant_location: @invalid_attrs)
        |> render_submit()

      assert html =~ "can&#39;t be blank"
      assert html =~ "New Merchant location"
    end

    test "handles validation errors when updating merchant_location", %{
      conn: conn,
      merchant_location: merchant_location
    } do
      {:ok, form_live, _html} =
        live(conn, ~p"/merchant_locations/#{merchant_location}/edit")

      html =
        form_live
        |> form("#merchant_location-form", merchant_location: @invalid_attrs)
        |> render_submit()

      assert html =~ "can&#39;t be blank"
      assert html =~ "Edit Merchant location"
    end
  end

  describe "Return path handling" do
    setup [:create_merchant_location]

    test "new form redirects to merchant show page", %{conn: conn, user: user} do
      {:ok, form_live, _html} = live(conn, ~p"/merchant_locations/new")

      merchant = Trays.Merchants.get_or_create_default_merchant(user.id)

      assert {:ok, show_live, _html} =
               form_live
               |> form("#merchant_location-form", merchant_location: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/merchants/#{merchant}")

      assert render(show_live) =~ "Merchant location created successfully"
    end

    test "edit form redirects to merchant show page", %{
      conn: conn,
      merchant_location: merchant_location
    } do
      {:ok, form_live, _html} =
        live(conn, ~p"/merchant_locations/#{merchant_location}/edit")

      merchant_location = Trays.Repo.preload(merchant_location, :merchant)

      assert {:ok, show_live, _html} =
               form_live
               |> form("#merchant_location-form", merchant_location: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/merchants/#{merchant_location.merchant}")

      assert render(show_live) =~ "Merchant location updated successfully"
    end
  end

  describe "Merchant creation on first location" do
    test "creates default merchant when user has no merchant", %{conn: conn, user: user} do
      {:ok, form_live, _html} = live(conn, ~p"/merchant_locations/new")

      merchant = Trays.Merchants.get_or_create_default_merchant(user.id)

      assert {:ok, _show_live, html} =
               form_live
               |> form("#merchant_location-form", merchant_location: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/merchants/#{merchant}")

      assert html =~ "Merchant location created successfully"
    end
  end
end
