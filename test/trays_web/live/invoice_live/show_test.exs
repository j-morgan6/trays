defmodule TraysWeb.InvoiceLive.ShowTest do
  use TraysWeb.ConnCase

  import Phoenix.LiveViewTest
  import Trays.InvoicesFixtures
  import Trays.MerchantLocationsFixtures

  setup do
    user = Trays.AccountsFixtures.user_fixture(%{type: :merchant})
    conn = Phoenix.ConnTest.build_conn()
    merchant_location = merchant_location_fixture(%{user: user})

    %{
      conn: TraysWeb.ConnCase.log_in_user(conn, user),
      user: user,
      merchant_location: merchant_location
    }
  end

  describe "Invoice show page" do
    setup [:create_invoice]

    test "displays invoice header with number", %{
      conn: conn,
      merchant_location: location,
      invoice: invoice
    } do
      {:ok, _show_live, html} =
        live(conn, ~p"/merchant_locations/#{location}/invoices/#{invoice}")

      assert html =~ "Invoice"
      assert html =~ invoice.number
    end

    test "displays customer information", %{
      conn: conn,
      merchant_location: location,
      invoice: invoice
    } do
      {:ok, _show_live, html} =
        live(conn, ~p"/merchant_locations/#{location}/invoices/#{invoice}")

      assert html =~ invoice.name
      assert html =~ invoice.email
      assert html =~ invoice.phone_number
      assert html =~ invoice.address
    end

    test "displays invoice details", %{
      conn: conn,
      merchant_location: location,
      invoice: invoice
    } do
      {:ok, _show_live, html} =
        live(conn, ~p"/merchant_locations/#{location}/invoices/#{invoice}")

      assert html =~ "Total Amount"
      assert html =~ "GST/HST"
      assert html =~ Decimal.to_string(invoice.total_amount, :normal)
      assert html =~ Decimal.to_string(invoice.gst_hst, :normal)
    end

    test "displays payment terms and delivery date", %{
      conn: conn,
      merchant_location: location,
      invoice: invoice
    } do
      {:ok, _show_live, html} =
        live(conn, ~p"/merchant_locations/#{location}/invoices/#{invoice}")

      assert html =~ "Payment Terms"
      assert html =~ "Delivery Date"
    end

    test "displays status badge", %{
      conn: conn,
      merchant_location: location,
      invoice: invoice
    } do
      {:ok, _show_live, html} =
        live(conn, ~p"/merchant_locations/#{location}/invoices/#{invoice}")

      assert html =~ "Status"
    end

    test "shows edit and delete buttons", %{
      conn: conn,
      merchant_location: location,
      invoice: invoice
    } do
      {:ok, _show_live, html} =
        live(conn, ~p"/merchant_locations/#{location}/invoices/#{invoice}")

      assert html =~ "Edit"
      assert html =~ "Delete"
    end

    test "shows back to location link", %{
      conn: conn,
      merchant_location: location,
      invoice: invoice
    } do
      {:ok, _show_live, html} =
        live(conn, ~p"/merchant_locations/#{location}/invoices/#{invoice}")

      assert html =~ "Back to Location"
      assert html =~ ~p"/merchant_locations/#{location}"
    end
  end

  defp create_invoice(%{merchant_location: location}) do
    invoice = invoice_fixture(%{merchant_location: location})
    %{invoice: invoice}
  end
end
