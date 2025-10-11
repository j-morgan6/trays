defmodule TraysWeb.MerchantLiveTest do
  use TraysWeb.ConnCase

  import Phoenix.LiveViewTest
  import Trays.MerchantsFixtures

  @update_attrs %{name: "some updated name", description: "some updated description"}
  @invalid_attrs %{name: nil, description: nil}

  setup :register_and_log_in_user

  defp create_merchant(%{user: user}) do
    merchant = merchant_fixture(%{user: user})

    %{merchant: merchant}
  end

  describe "Index" do
    setup [:create_merchant]

    test "displays merchant", %{conn: conn, merchant: merchant} do
      {:ok, _index_live, html} = live(conn, ~p"/merchants")

      assert html =~ merchant.name
      assert html =~ merchant.description
      assert html =~ "Locations"
    end

    test "updates merchant", %{conn: conn, merchant: merchant} do
      {:ok, index_live, _html} = live(conn, ~p"/merchants")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/merchants/#{merchant}/edit")

      assert render(form_live) =~ "Edit Merchant"

      assert form_live
             |> form("#merchant-form", merchant: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#merchant-form", merchant: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/merchants")

      html = render(index_live)
      assert html =~ "Merchant updated successfully"
      assert html =~ "some updated name"
    end

    test "displays empty state when no locations", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/merchants")

      assert html =~ "No locations yet"
      assert html =~ "Add your first location"
    end
  end
end
