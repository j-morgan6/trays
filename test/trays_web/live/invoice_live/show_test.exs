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
      assert html =~ Money.to_string(invoice.total_amount)
      assert html =~ Money.to_string(invoice.gst_hst)
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

    test "deletes invoice and redirects to location", %{
      conn: conn,
      merchant_location: location,
      invoice: invoice
    } do
      {:ok, show_live, _html} =
        live(conn, ~p"/merchant_locations/#{location}/invoices/#{invoice}")

      assert {:ok, _index_live, html} =
               show_live
               |> element("a", "Delete")
               |> render_click()
               |> follow_redirect(conn, ~p"/merchant_locations/#{location}")

      assert html =~ "Invoice deleted successfully"
      refute html =~ invoice.number
    end

    test "displays paid status badge for paid invoices", %{
      conn: conn,
      merchant_location: location
    } do
      paid_invoice =
        invoice_fixture(%{
          merchant_location: location,
          status: :paid
        })

      {:ok, _show_live, html} =
        live(conn, ~p"/merchant_locations/#{location}/invoices/#{paid_invoice}")

      assert html =~ "Paid"
      assert html =~ "bg-green-100"
    end

    test "displays outstanding status badge for outstanding invoices", %{
      conn: conn,
      merchant_location: location
    } do
      outstanding_invoice =
        invoice_fixture(%{
          merchant_location: location,
          status: :outstanding
        })

      {:ok, _show_live, html} =
        live(conn, ~p"/merchant_locations/#{location}/invoices/#{outstanding_invoice}")

      assert html =~ "Outstanding"
      assert html =~ "bg-yellow-100"
    end

    test "displays 'Due Now' for now payment terms", %{
      conn: conn,
      merchant_location: location
    } do
      invoice =
        invoice_fixture(%{
          merchant_location: location,
          terms: :now
        })

      {:ok, _show_live, html} =
        live(conn, ~p"/merchant_locations/#{location}/invoices/#{invoice}")

      assert html =~ "Due Now"
    end

    test "displays 'Net 15 Days' for net15 payment terms", %{
      conn: conn,
      merchant_location: location
    } do
      invoice =
        invoice_fixture(%{
          merchant_location: location,
          terms: :net15
        })

      {:ok, _show_live, html} =
        live(conn, ~p"/merchant_locations/#{location}/invoices/#{invoice}")

      assert html =~ "Net 15 Days"
    end

    test "displays 'Net 30 Days' for net30 payment terms", %{
      conn: conn,
      merchant_location: location
    } do
      invoice =
        invoice_fixture(%{
          merchant_location: location,
          terms: :net30
        })

      {:ok, _show_live, html} =
        live(conn, ~p"/merchant_locations/#{location}/invoices/#{invoice}")

      assert html =~ "Net 30 Days"
    end

    test "calculates and displays subtotal correctly", %{
      conn: conn,
      merchant_location: location
    } do
      invoice =
        invoice_fixture(%{
          merchant_location: location,
          total_amount: Money.new(22_600),
          gst_hst: Money.new(2600)
        })

      {:ok, _show_live, html} =
        live(conn, ~p"/merchant_locations/#{location}/invoices/#{invoice}")

      assert html =~ "Subtotal"
      assert html =~ "200.00"
    end

    test "displays formatted delivery date", %{
      conn: conn,
      merchant_location: location
    } do
      invoice =
        invoice_fixture(%{
          merchant_location: location,
          delivery_date: ~D[2025-01-15]
        })

      {:ok, _show_live, html} =
        live(conn, ~p"/merchant_locations/#{location}/invoices/#{invoice}")

      assert html =~ "January 15, 2025"
    end
  end

  describe "Authorization" do
    test "only allows access to invoice owner", %{conn: conn} do
      other_user =
        Trays.AccountsFixtures.user_fixture(%{
          email: "other@example.com",
          type: :merchant
        })

      other_location = merchant_location_fixture(%{user: other_user})
      other_invoice = invoice_fixture(%{merchant_location: other_location})

      assert_raise Ecto.NoResultsError, fn ->
        live(conn, ~p"/merchant_locations/#{other_location}/invoices/#{other_invoice}")
      end
    end
  end

  defp create_invoice(%{merchant_location: location}) do
    invoice = invoice_fixture(%{merchant_location: location})
    %{invoice: invoice}
  end
end
