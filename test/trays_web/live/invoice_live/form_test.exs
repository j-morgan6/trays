defmodule TraysWeb.InvoiceLive.FormTest do
  use TraysWeb.ConnCase

  import Phoenix.LiveViewTest
  import Trays.InvoicesFixtures
  import Trays.MerchantLocationsFixtures
  import Ecto.Query

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

    test "validates total_amount on blur", %{conn: conn, merchant_location: location} do
      {:ok, form_live, _html} =
        live(conn, ~p"/merchant_locations/#{location}/invoices/new")

      form_live
      |> form("#invoice-form", invoice: %{total_amount: "-10"})
      |> render_change()

      html =
        form_live
        |> element("input[name='invoice[total_amount]']")
        |> render_blur()

      assert html =~ "must be greater than"
    end

    test "validates gst_hst on blur", %{conn: conn, merchant_location: location} do
      {:ok, form_live, _html} =
        live(conn, ~p"/merchant_locations/#{location}/invoices/new")

      form_live
      |> form("#invoice-form", invoice: %{gst_hst: "-5"})
      |> render_change()

      html =
        form_live
        |> element("input[name='invoice[gst_hst]']")
        |> render_blur()

      assert html =~ "must be greater than or equal to"
    end

    test "displays line items section", %{conn: conn, merchant_location: location} do
      {:ok, _form_live, html} =
        live(conn, ~p"/merchant_locations/#{location}/invoices/new")

      assert html =~ "Line Items"
      assert html =~ "Description"
      assert html =~ "Quantity"
      assert html =~ "Amount ($)"
      assert html =~ "Add line items below, then save the entire invoice"
    end

    test "displays subtotal field", %{conn: conn, merchant_location: location} do
      {:ok, _form_live, html} =
        live(conn, ~p"/merchant_locations/#{location}/invoices/new")

      assert html =~ "Subtotal"
      assert html =~ "$0.00"
    end

    test "line item form allows adding items for new invoice", %{
      conn: conn,
      merchant_location: location
    } do
      {:ok, form_live, _html} =
        live(conn, ~p"/merchant_locations/#{location}/invoices/new")

      button_html = form_live |> element("button", "Add") |> render()
      refute button_html =~ "disabled"
    end

    test "adds temp line item successfully on new invoice", %{
      conn: conn,
      merchant_location: location
    } do
      {:ok, form_live, _html} =
        live(conn, ~p"/merchant_locations/#{location}/invoices/new")

      html =
        render_hook(form_live, "add_temp_line_item_from_inputs", %{
          "description" => "Test Item",
          "quantity" => "2",
          "amount" => "50.00"
        })

      assert html =~ "Line item added successfully"
      assert html =~ "Test Item"
      assert html =~ "100.00"
    end

    test "creates invoice with temp line items", %{conn: conn, merchant_location: location} do
      {:ok, form_live, _html} =
        live(conn, ~p"/merchant_locations/#{location}/invoices/new")

      render_hook(form_live, "add_temp_line_item_from_inputs", %{
        "description" => "Widget",
        "quantity" => "3",
        "amount" => "25.00"
      })

      assert {:ok, _show_live, html} =
               form_live
               |> form("#invoice-form", invoice: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/merchant_locations/#{location}")

      assert html =~ "Invoice created successfully"

      invoice =
        from(i in Trays.Invoices.Invoice, where: i.number == "INV-001", preload: :line_items)
        |> Trays.Repo.one!()

      assert length(invoice.line_items) == 1
      assert hd(invoice.line_items).description == "Widget"
    end

    test "removes temp line item on new invoice", %{conn: conn, merchant_location: location} do
      {:ok, form_live, _html} =
        live(conn, ~p"/merchant_locations/#{location}/invoices/new")

      render_hook(form_live, "add_temp_line_item_from_inputs", %{
        "description" => "Test Item",
        "quantity" => "2",
        "amount" => "50.00"
      })

      html =
        form_live
        |> element("button[phx-click='remove_temp_line_item'][phx-value-index='0']")
        |> render_click()

      assert html =~ "Line item removed successfully"
      refute html =~ "Test Item"
      assert html =~ "No line items yet"
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

    test "displays subtotal with zero when no line items", %{
      conn: conn,
      merchant_location: location,
      invoice: invoice
    } do
      {:ok, _form_live, html} =
        live(conn, ~p"/merchant_locations/#{location}/invoices/#{invoice}/edit")

      assert html =~ "Subtotal"
      assert html =~ "$0.00"
    end

    test "adds temp line item successfully during edit", %{
      conn: conn,
      merchant_location: location,
      invoice: invoice
    } do
      {:ok, form_live, _html} =
        live(conn, ~p"/merchant_locations/#{location}/invoices/#{invoice}/edit")

      html =
        render_hook(form_live, "add_temp_line_item_from_inputs", %{
          "description" => "Temp Item",
          "quantity" => "3",
          "amount" => "75.00"
        })

      assert html =~ "Line item added successfully"
      assert html =~ "Temp Item"
      assert html =~ "225.00"
    end

    test "saves temp line items when updating invoice", %{
      conn: conn,
      merchant_location: location,
      invoice: invoice
    } do
      {:ok, form_live, _html} =
        live(conn, ~p"/merchant_locations/#{location}/invoices/#{invoice}/edit")

      render_hook(form_live, "add_temp_line_item_from_inputs", %{
        "description" => "Widget",
        "quantity" => "2",
        "amount" => "50.00"
      })

      render_hook(form_live, "add_temp_line_item_from_inputs", %{
        "description" => "Gadget",
        "quantity" => "1",
        "amount" => "100.00"
      })

      assert {:ok, _show_live, html} =
               form_live
               |> form("#invoice-form", invoice: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/merchant_locations/#{location}")

      assert html =~ "Invoice updated successfully"

      updated_invoice =
        from(i in Trays.Invoices.Invoice, where: i.id == ^invoice.id, preload: :line_items)
        |> Trays.Repo.one!()

      assert length(updated_invoice.line_items) == 2
      descriptions = Enum.map(updated_invoice.line_items, & &1.description)
      assert "Widget" in descriptions
      assert "Gadget" in descriptions
    end

    test "removes temp line item during edit", %{
      conn: conn,
      merchant_location: location,
      invoice: invoice
    } do
      {:ok, form_live, _html} =
        live(conn, ~p"/merchant_locations/#{location}/invoices/#{invoice}/edit")

      render_hook(form_live, "add_temp_line_item_from_inputs", %{
        "description" => "Temp Item",
        "quantity" => "2",
        "amount" => "50.00"
      })

      html =
        form_live
        |> element("button[phx-click='remove_temp_line_item'][phx-value-index='0']")
        |> render_click()

      assert html =~ "Line item removed successfully"
      refute html =~ "Temp Item"
    end

    test "calculates subtotal combining existing and temp line items", %{
      conn: conn,
      merchant_location: location,
      invoice: invoice
    } do
      Trays.Invoices.create_line_item(%{
        invoice_id: invoice.id,
        description: "Existing Item",
        quantity: 2,
        amount: Money.new(50_00)
      })

      {:ok, form_live, html} =
        live(conn, ~p"/merchant_locations/#{location}/invoices/#{invoice}/edit")

      assert html =~ "100.00"

      html =
        render_hook(form_live, "add_temp_line_item_from_inputs", %{
          "description" => "Temp Item",
          "quantity" => "1",
          "amount" => "25.00"
        })

      assert html =~ "125.00"
    end

    test "saves temp line items along with existing line items", %{
      conn: conn,
      merchant_location: location,
      invoice: invoice
    } do
      Trays.Invoices.create_line_item(%{
        invoice_id: invoice.id,
        description: "Existing Item",
        quantity: 1,
        amount: Money.new(10_000)
      })

      {:ok, form_live, _html} =
        live(conn, ~p"/merchant_locations/#{location}/invoices/#{invoice}/edit")

      render_hook(form_live, "add_temp_line_item_from_inputs", %{
        "description" => "New Item",
        "quantity" => "2",
        "amount" => "75.00"
      })

      assert {:ok, _show_live, html} =
               form_live
               |> form("#invoice-form", invoice: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/merchant_locations/#{location}")

      assert html =~ "Invoice updated successfully"

      updated_invoice =
        from(i in Trays.Invoices.Invoice, where: i.id == ^invoice.id, preload: :line_items)
        |> Trays.Repo.one!()

      assert length(updated_invoice.line_items) == 2
      descriptions = Enum.map(updated_invoice.line_items, & &1.description)
      assert "Existing Item" in descriptions
      assert "New Item" in descriptions
    end
  end

  describe "Line Items" do
    setup [:create_invoice]

    test "adds line item successfully", %{
      conn: conn,
      merchant_location: location,
      invoice: invoice
    } do
      {:ok, form_live, _html} =
        live(conn, ~p"/merchant_locations/#{location}/invoices/#{invoice}/edit")

      html =
        render_hook(form_live, "add_line_item", %{
          "line_item" => %{
            "description" => "Test Item",
            "quantity" => "2",
            "amount" => "50.00"
          }
        })

      assert html =~ "Line item added successfully"
      assert has_element?(form_live, "td", "Test Item")
    end

    test "calculates subtotal for single line item", %{
      conn: conn,
      merchant_location: location,
      invoice: invoice
    } do
      Trays.Invoices.create_line_item(%{
        invoice_id: invoice.id,
        description: "Test Item",
        quantity: 2,
        amount: Money.new(50_00)
      })

      {:ok, _form_live, html} =
        live(conn, ~p"/merchant_locations/#{location}/invoices/#{invoice}/edit")

      assert html =~ "Test Item"
      assert html =~ "100.00"
    end

    test "deletes line item successfully", %{
      conn: conn,
      merchant_location: location,
      invoice: invoice
    } do
      {:ok, form_live, _html} =
        live(conn, ~p"/merchant_locations/#{location}/invoices/#{invoice}/edit")

      render_hook(form_live, "add_line_item", %{
        "line_item" => %{
          "description" => "Test Item",
          "quantity" => "2",
          "amount" => "50.00"
        }
      })

      line_item = Trays.Repo.one!(Trays.Invoices.LineItem)

      assert form_live
             |> element(
               "button[phx-click='delete_line_item'][phx-value-id='#{line_item.id}']",
               ""
             )
             |> render_click() =~ "Line item deleted successfully"

      refute has_element?(form_live, "td", "Test Item")
    end

    test "displays line items in table", %{
      conn: conn,
      merchant_location: location,
      invoice: invoice
    } do
      Trays.Invoices.create_line_item(%{
        invoice_id: invoice.id,
        description: "Widget",
        quantity: 5,
        amount: Money.new(10_00)
      })

      {:ok, _form_live, html} =
        live(conn, ~p"/merchant_locations/#{location}/invoices/#{invoice}/edit")

      assert html =~ "Widget"
      assert html =~ "5"
      assert html =~ "10.00"
      assert html =~ "50.00"
    end

    test "shows empty state when no line items", %{
      conn: conn,
      merchant_location: location,
      invoice: invoice
    } do
      {:ok, _form_live, html} =
        live(conn, ~p"/merchant_locations/#{location}/invoices/#{invoice}/edit")

      assert html =~ "No line items yet"
    end

    test "updates subtotal after deleting line item", %{
      conn: conn,
      merchant_location: location,
      invoice: invoice
    } do
      {:ok, form_live, _html} =
        live(conn, ~p"/merchant_locations/#{location}/invoices/#{invoice}/edit")

      render_hook(form_live, :add_line_item, %{
        "line_item" => %{
          "description" => "Item 1",
          "quantity" => "2",
          "amount" => "50.00"
        }
      })

      render_hook(form_live, :add_line_item, %{
        "line_item" => %{
          "description" => "Item 2",
          "quantity" => "1",
          "amount" => "25.00"
        }
      })

      html = render(form_live)
      assert html =~ "125.00"

      line_item =
        from(l in Trays.Invoices.LineItem, where: l.description == "Item 1")
        |> Trays.Repo.one!()

      html =
        form_live
        |> element("button[phx-click='delete_line_item'][phx-value-id='#{line_item.id}']", "")
        |> render_click()

      assert html =~ "25.00"
    end
  end

  describe "validate_line_item event" do
    test "validates line item on change", %{conn: conn, merchant_location: location} do
      {:ok, form_live, _html} =
        live(conn, ~p"/merchant_locations/#{location}/invoices/new")

      html =
        render_hook(form_live, "validate_line_item", %{
          "line_item" => %{
            "description" => "",
            "quantity" => "",
            "amount" => ""
          }
        })

      assert html =~ "can&#39;t be blank"
    end

    test "validates line item with valid data", %{conn: conn, merchant_location: location} do
      {:ok, form_live, _html} =
        live(conn, ~p"/merchant_locations/#{location}/invoices/new")

      html =
        render_hook(form_live, "validate_line_item", %{
          "line_item" => %{
            "description" => "Test Item",
            "quantity" => "2",
            "amount" => "50.00"
          }
        })

      refute html =~ "can&#39;t be blank"
    end
  end

  describe "add_temp_line_item event" do
    test "adds temp line item via form submission", %{conn: conn, merchant_location: location} do
      {:ok, form_live, _html} =
        live(conn, ~p"/merchant_locations/#{location}/invoices/new")

      html =
        render_hook(form_live, "add_temp_line_item", %{
          "line_item" => %{
            "description" => "Form Item",
            "quantity" => "3",
            "amount" => "40.00"
          }
        })

      assert html =~ "Line item added successfully"
      assert html =~ "Form Item"
      assert html =~ "120.00"
    end

    test "shows error for invalid temp line item via form", %{
      conn: conn,
      merchant_location: location
    } do
      {:ok, form_live, _html} =
        live(conn, ~p"/merchant_locations/#{location}/invoices/new")

      html =
        render_hook(form_live, "add_temp_line_item", %{
          "line_item" => %{
            "description" => "",
            "quantity" => "",
            "amount" => ""
          }
        })

      assert html =~ "Please check the line item fields for errors"
    end
  end

  describe "invalid temp line item handling" do
    test "shows error for invalid temp line item from inputs", %{
      conn: conn,
      merchant_location: location
    } do
      {:ok, form_live, _html} =
        live(conn, ~p"/merchant_locations/#{location}/invoices/new")

      html =
        render_hook(form_live, "add_temp_line_item_from_inputs", %{
          "description" => "",
          "quantity" => "",
          "amount" => ""
        })

      assert html =~ "Please check the line item fields for errors"
    end
  end

  describe "add_line_item error case" do
    setup [:create_invoice]

    test "shows error when line item creation fails due to validation", %{
      conn: conn,
      merchant_location: location,
      invoice: invoice
    } do
      {:ok, form_live, _html} =
        live(conn, ~p"/merchant_locations/#{location}/invoices/#{invoice}/edit")

      html =
        render_hook(form_live, "add_line_item", %{
          "line_item" => %{
            "description" => "",
            "quantity" => "0",
            "amount" => "-10.00"
          }
        })

      assert html =~ "can&#39;t be blank"
    end
  end

  describe "save_invoice error cases" do
    setup [:create_invoice]

    test "shows error when updating invoice with invalid data", %{
      conn: conn,
      merchant_location: location,
      invoice: invoice
    } do
      {:ok, form_live, _html} =
        live(conn, ~p"/merchant_locations/#{location}/invoices/#{invoice}/edit")

      html =
        form_live
        |> form("#invoice-form", invoice: %{name: nil, email: "invalid"})
        |> render_submit()

      assert html =~ "can&#39;t be blank"
    end
  end

  defp create_invoice(%{merchant_location: location}) do
    invoice = invoice_fixture(%{merchant_location: location})
    %{invoice: invoice}
  end
end
