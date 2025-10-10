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

  setup :register_and_log_in_user

  defp create_merchant_location(%{user: user}) do
    merchant_location = merchant_location_fixture(%{user: user})

    %{merchant_location: merchant_location}
  end

  describe "Index" do
    setup [:create_merchant_location]

    test "lists all merchant_locations", %{conn: conn, merchant_location: merchant_location} do
      {:ok, _index_live, html} = live(conn, ~p"/merchant_locations")

      assert html =~ "Listing Merchant locations"
      assert html =~ merchant_location.street1
    end

    test "saves new merchant_location", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/merchant_locations")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Merchant location")
               |> render_click()
               |> follow_redirect(conn, ~p"/merchant_locations/new")

      assert render(form_live) =~ "New Merchant location"

      assert form_live
             |> form("#merchant_location-form", merchant_location: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#merchant_location-form", merchant_location: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/merchant_locations")

      html = render(index_live)
      assert html =~ "Merchant location created successfully"
      assert html =~ "some street1"
    end

    test "updates merchant_location in listing", %{
      conn: conn,
      merchant_location: merchant_location
    } do
      {:ok, index_live, _html} = live(conn, ~p"/merchant_locations")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#merchant_locations-#{merchant_location.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/merchant_locations/#{merchant_location}/edit")

      assert render(form_live) =~ "Edit Merchant location"

      assert form_live
             |> form("#merchant_location-form", merchant_location: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#merchant_location-form", merchant_location: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/merchant_locations")

      html = render(index_live)
      assert html =~ "Merchant location updated successfully"
      assert html =~ "some updated street1"
    end

    test "deletes merchant_location in listing", %{
      conn: conn,
      merchant_location: merchant_location
    } do
      {:ok, index_live, _html} = live(conn, ~p"/merchant_locations")

      assert index_live
             |> element("#merchant_locations-#{merchant_location.id} a", "Delete")
             |> render_click()

      refute has_element?(index_live, "#merchant_locations-#{merchant_location.id}")
    end
  end

  describe "Show" do
    setup [:create_merchant_location]

    test "displays merchant_location", %{conn: conn, merchant_location: merchant_location} do
      {:ok, _show_live, html} = live(conn, ~p"/merchant_locations/#{merchant_location}")

      assert html =~ "Show Merchant location"
      assert html =~ merchant_location.street1
    end

    test "updates merchant_location and returns to show", %{
      conn: conn,
      merchant_location: merchant_location
    } do
      {:ok, show_live, _html} = live(conn, ~p"/merchant_locations/#{merchant_location}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(
                 conn,
                 ~p"/merchant_locations/#{merchant_location}/edit?return_to=show"
               )

      assert render(form_live) =~ "Edit Merchant location"

      assert form_live
             |> form("#merchant_location-form", merchant_location: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#merchant_location-form", merchant_location: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/merchant_locations/#{merchant_location}")

      html = render(show_live)
      assert html =~ "Merchant location updated successfully"
      assert html =~ "some updated street1"
    end
  end
end
