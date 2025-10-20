defmodule TraysWeb.InvoiceLive.FormTest do
  use TraysWeb.ConnCase

  import Phoenix.LiveViewTest
  import Trays.InvoicesFixtures
  import Trays.MerchantLocationsFixtures

  @create_attrs %{
    name: "John Doe",
    email: "john@example.com",
    address: "123 Main St",
    phone_number: "555-1234",
    number: "INV-001",
    gst_hst: "13.00",
    total_amount: "113.00",
    terms: "net30",
    delivery_date: "2025-01-15",
    status: "outstanding"
  }

  @update_attrs %{
    name: "Jane Smith",
    email: "jane@example.com",
    address: "456 Oak Ave",
    phone_number: "555-5678",
    number: "INV-002",
    gst_hst: "26.00",
    total_amount: "226.00",
    terms: "net15",
    delivery_date: "2025-02-01",
    status: "paid"
  }

  @invalid_attrs %{
    name: nil,
    email: "invalid-email",
    address: nil,
    phone_number: nil,
    number: nil,
    gst_hst: nil,
    total_amount: nil,
    delivery_date: nil
  }

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

  describe "New invoice form" do
    test "renders form", %{conn: conn, merchant_location: location} do
      {:ok, _form_live, html} =
        live(conn, ~p"/merchant_locations/#{location}/invoices/new")

      assert html =~ "New Invoice"
      assert html =~ "Customer Name"
      assert html =~ "Invoice Number"
    end

    test "validates on change", %{conn: conn, merchant_location: location} do
      {:ok, form_live, _html} =
        live(conn, ~p"/merchant_locations/#{location}/invoices/new")

      assert form_live
             |> form("#invoice-form", invoice: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"
    end

    test "creates invoice successfully", %{conn: conn, merchant_location: location} do
      {:ok, form_live, _html} =
        live(conn, ~p"/merchant_locations/#{location}/invoices/new")

      assert {:ok, _show_live, html} =
               form_live
               |> form("#invoice-form", invoice: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/merchant_locations/#{location}")

      assert html =~ "Invoice created successfully"
      assert html =~ "INV-001"
    end

    test "shows validation errors on submit", %{conn: conn, merchant_location: location} do
      {:ok, form_live, _html} =
        live(conn, ~p"/merchant_locations/#{location}/invoices/new")

      html =
        form_live
        |> form("#invoice-form", invoice: @invalid_attrs)
        |> render_submit()

      assert html =~ "can&#39;t be blank"
    end
  end

  describe "Edit invoice form" do
    setup [:create_invoice]

    test "renders form with existing data", %{
      conn: conn,
      merchant_location: location,
      invoice: invoice
    } do
      {:ok, _form_live, html} =
        live(conn, ~p"/merchant_locations/#{location}/invoices/#{invoice}/edit")

      assert html =~ "Edit Invoice"
      assert html =~ invoice.name
      assert html =~ invoice.number
    end

    test "updates invoice successfully", %{
      conn: conn,
      merchant_location: location,
      invoice: invoice
    } do
      {:ok, form_live, _html} =
        live(conn, ~p"/merchant_locations/#{location}/invoices/#{invoice}/edit")

      assert {:ok, _show_live, html} =
               form_live
               |> form("#invoice-form", invoice: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/merchant_locations/#{location}")

      assert html =~ "Invoice updated successfully"
      assert html =~ "Jane Smith"
    end

    test "validates on change", %{
      conn: conn,
      merchant_location: location,
      invoice: invoice
    } do
      {:ok, form_live, _html} =
        live(conn, ~p"/merchant_locations/#{location}/invoices/#{invoice}/edit")

      assert form_live
             |> form("#invoice-form", invoice: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"
    end
  end

  defp create_invoice(%{merchant_location: location}) do
    invoice = invoice_fixture(%{merchant_location: location})
    %{invoice: invoice}
  end
end
