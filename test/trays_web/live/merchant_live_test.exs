defmodule TraysWeb.MerchantLiveTest do
  use TraysWeb.ConnCase

  import Phoenix.LiveViewTest
  import Trays.MerchantsFixtures

  @create_attrs %{name: "some name", description: "some description"}
  @update_attrs %{name: "some updated name", description: "some updated description"}
  @invalid_attrs %{name: nil, description: nil}

  setup :register_and_log_in_user

  defp create_merchant(%{user: user}) do
    merchant = merchant_fixture(%{user: user})

    %{merchant: merchant}
  end

  describe "Index" do
    setup [:create_merchant]

    test "lists all merchants", %{conn: conn, merchant: merchant} do
      {:ok, _index_live, html} = live(conn, ~p"/merchants")

      assert html =~ "Listing Merchants"
      assert html =~ merchant.name
    end

    test "saves new merchant", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/merchants")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Merchant")
               |> render_click()
               |> follow_redirect(conn, ~p"/merchants/new")

      assert render(form_live) =~ "New Merchant"

      assert form_live
             |> form("#merchant-form", merchant: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#merchant-form", merchant: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/merchants")

      html = render(index_live)
      assert html =~ "Merchant created successfully"
      assert html =~ "some name"
    end

    test "updates merchant in listing", %{conn: conn, merchant: merchant} do
      {:ok, index_live, _html} = live(conn, ~p"/merchants")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#merchants-#{merchant.id} a", "Edit")
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

    test "deletes merchant in listing", %{conn: conn, merchant: merchant} do
      {:ok, index_live, _html} = live(conn, ~p"/merchants")

      assert index_live |> element("#merchants-#{merchant.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#merchants-#{merchant.id}")
    end
  end

  describe "Show" do
    setup [:create_merchant]

    test "displays merchant", %{conn: conn, merchant: merchant} do
      {:ok, _show_live, html} = live(conn, ~p"/merchants/#{merchant}")

      assert html =~ "Show Merchant"
      assert html =~ merchant.name
    end

    test "updates merchant and returns to show", %{conn: conn, merchant: merchant} do
      {:ok, show_live, _html} = live(conn, ~p"/merchants/#{merchant}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/merchants/#{merchant}/edit?return_to=show")

      assert render(form_live) =~ "Edit Merchant"

      assert form_live
             |> form("#merchant-form", merchant: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#merchant-form", merchant: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/merchants/#{merchant}")

      html = render(show_live)
      assert html =~ "Merchant updated successfully"
      assert html =~ "some updated name"
    end
  end
end
