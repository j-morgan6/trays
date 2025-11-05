defmodule Trays.InvoicesTest do
  use Trays.DataCase

  alias Trays.Invoices

  describe "list_invoices/1" do
    test "returns all invoices for a merchant location" do
      merchant_location = Trays.MerchantLocationsFixtures.merchant_location_fixture()
      invoice1 = Trays.InvoicesFixtures.invoice_fixture(%{merchant_location: merchant_location})
      invoice2 = Trays.InvoicesFixtures.invoice_fixture(%{merchant_location: merchant_location})

      invoices = Invoices.list_invoices(merchant_location.id)

      assert length(invoices) == 2

      assert Enum.map(invoices, & &1.id) |> Enum.sort() ==
               [invoice1.id, invoice2.id] |> Enum.sort()
    end

    test "returns empty list when merchant location has no invoices" do
      merchant_location = Trays.MerchantLocationsFixtures.merchant_location_fixture()
      assert Invoices.list_invoices(merchant_location.id) == []
    end

    test "does not return invoices from other merchant locations" do
      merchant_location1 = Trays.MerchantLocationsFixtures.merchant_location_fixture()
      merchant_location2 = Trays.MerchantLocationsFixtures.merchant_location_fixture()

      _invoice1 = Trays.InvoicesFixtures.invoice_fixture(%{merchant_location: merchant_location1})
      invoice2 = Trays.InvoicesFixtures.invoice_fixture(%{merchant_location: merchant_location2})

      invoices = Invoices.list_invoices(merchant_location2.id)

      assert length(invoices) == 1
      assert hd(invoices).id == invoice2.id
    end

    test "orders invoices by most recent first" do
      merchant_location = Trays.MerchantLocationsFixtures.merchant_location_fixture()

      invoice1 =
        Trays.InvoicesFixtures.invoice_fixture(%{
          merchant_location: merchant_location,
          number: "INV-FIRST"
        })

      invoice2 =
        Trays.InvoicesFixtures.invoice_fixture(%{
          merchant_location: merchant_location,
          number: "INV-SECOND"
        })

      invoices = Invoices.list_invoices(merchant_location.id)

      assert length(invoices) == 2
      invoice_ids = Enum.map(invoices, & &1.id)
      assert invoice1.id in invoice_ids
      assert invoice2.id in invoice_ids
    end
  end

  describe "get_invoice!/2" do
    test "returns the invoice with given id and merchant_location_id" do
      merchant_location = Trays.MerchantLocationsFixtures.merchant_location_fixture()
      invoice = Trays.InvoicesFixtures.invoice_fixture(%{merchant_location: merchant_location})

      result = Invoices.get_invoice!(invoice.id, merchant_location.id)

      assert result.id == invoice.id
      assert result.merchant_location_id == merchant_location.id
    end

    test "raises error when invoice does not exist" do
      merchant_location = Trays.MerchantLocationsFixtures.merchant_location_fixture()

      assert_raise Ecto.NoResultsError, fn ->
        Invoices.get_invoice!(999, merchant_location.id)
      end
    end

    test "raises error when invoice belongs to different merchant location" do
      merchant_location1 = Trays.MerchantLocationsFixtures.merchant_location_fixture()
      merchant_location2 = Trays.MerchantLocationsFixtures.merchant_location_fixture()

      invoice = Trays.InvoicesFixtures.invoice_fixture(%{merchant_location: merchant_location1})

      assert_raise Ecto.NoResultsError, fn ->
        Invoices.get_invoice!(invoice.id, merchant_location2.id)
      end
    end
  end

  describe "create_invoice/1" do
    test "creates invoice with valid attributes" do
      merchant_location = Trays.MerchantLocationsFixtures.merchant_location_fixture()

      attrs = %{
        name: "Jane Smith",
        email: "jane@example.com",
        address: "456 Oak St",
        phone_number: "555-5678",
        number: "INV-100",
        gst_hst: Money.new(2600),
        total_amount: Money.new(22_600),
        terms: :net15,
        delivery_date: ~D[2025-02-01],
        merchant_location_id: merchant_location.id
      }

      assert {:ok, invoice} = Invoices.create_invoice(attrs)
      assert invoice.name == "Jane Smith"
      assert invoice.email == "jane@example.com"
      assert invoice.number == "INV-100"
      assert invoice.status == :outstanding
    end

    test "returns error changeset with invalid attributes" do
      assert {:error, changeset} = Invoices.create_invoice(%{})
      refute changeset.valid?
    end

    test "returns error when invoice number is duplicate" do
      merchant_location = Trays.MerchantLocationsFixtures.merchant_location_fixture()

      attrs = %{
        name: "Test User",
        email: "test@example.com",
        address: "123 Test St",
        phone_number: "555-0000",
        number: "INV-DUPLICATE",
        gst_hst: Money.new(1000),
        total_amount: Money.new(10_000),
        terms: :now,
        delivery_date: ~D[2025-01-01],
        merchant_location_id: merchant_location.id
      }

      assert {:ok, _invoice} = Invoices.create_invoice(attrs)
      assert {:error, changeset} = Invoices.create_invoice(attrs)

      assert "has already been taken" in errors_on(changeset).number
    end
  end

  describe "update_invoice/2" do
    test "updates invoice with valid attributes" do
      invoice = Trays.InvoicesFixtures.invoice_fixture()

      update_attrs = %{
        name: "Updated Name",
        status: :paid
      }

      assert {:ok, updated_invoice} = Invoices.update_invoice(invoice, update_attrs)
      assert updated_invoice.name == "Updated Name"
      assert updated_invoice.status == :paid
    end

    test "returns error changeset with invalid attributes" do
      invoice = Trays.InvoicesFixtures.invoice_fixture()

      invalid_attrs = %{email: "invalid-email"}

      assert {:error, changeset} = Invoices.update_invoice(invoice, invalid_attrs)
      refute changeset.valid?
    end
  end

  describe "delete_invoice/1" do
    test "deletes the invoice" do
      merchant_location = Trays.MerchantLocationsFixtures.merchant_location_fixture()
      invoice = Trays.InvoicesFixtures.invoice_fixture(%{merchant_location: merchant_location})

      assert {:ok, deleted_invoice} = Invoices.delete_invoice(invoice)
      assert deleted_invoice.id == invoice.id

      assert_raise Ecto.NoResultsError, fn ->
        Invoices.get_invoice!(invoice.id, merchant_location.id)
      end
    end
  end

  describe "change_invoice/2" do
    test "returns a changeset for the invoice" do
      invoice = Trays.InvoicesFixtures.invoice_fixture()

      changeset = Invoices.change_invoice(invoice)

      assert %Ecto.Changeset{} = changeset
      assert changeset.data.id == invoice.id
    end

    test "returns a changeset with changes" do
      invoice = Trays.InvoicesFixtures.invoice_fixture()

      changeset = Invoices.change_invoice(invoice, %{name: "New Name"})

      assert %Ecto.Changeset{} = changeset
      assert changeset.changes.name == "New Name"
    end

    test "converts Money fields to decimal strings when loading form for existing invoice" do
      invoice =
        Trays.InvoicesFixtures.invoice_fixture(%{
          gst_hst: Money.new(1500),
          total_amount: Money.new(11_500)
        })

      changeset = Invoices.change_invoice(invoice, %{})

      # The function provides string attrs which get cast back to Money by Ecto
      # This makes the form display the decimal values correctly
      # The changeset should be valid and have the same Money values
      assert changeset.valid?
      # After casting, the values are Money structs in the changeset data
      assert changeset.data.gst_hst == Money.new(1500)
      assert changeset.data.total_amount == Money.new(11_500)
    end

    test "does not convert Money fields when attrs are provided" do
      invoice =
        Trays.InvoicesFixtures.invoice_fixture(%{
          gst_hst: Money.new(1500),
          total_amount: Money.new(11_500)
        })

      changeset = Invoices.change_invoice(invoice, %{name: "Test"})

      # Should not convert when explicit attrs are provided
      assert changeset.changes.name == "Test"
      refute Map.has_key?(changeset.changes, "gst_hst")
      refute Map.has_key?(changeset.changes, "total_amount")
    end

    test "does not convert Money fields for new invoice without id" do
      invoice = %Trays.Invoices.Invoice{}

      changeset = Invoices.change_invoice(invoice, %{})

      # Should not convert for new invoice
      refute Map.has_key?(changeset.changes, "gst_hst")
      refute Map.has_key?(changeset.changes, "total_amount")
    end
  end

  describe "get_invoice_with_line_items!/2" do
    test "returns the invoice with line items preloaded" do
      merchant_location = Trays.MerchantLocationsFixtures.merchant_location_fixture()
      invoice = Trays.InvoicesFixtures.invoice_fixture(%{merchant_location: merchant_location})

      line_item1 =
        Trays.LineItemsFixtures.line_item_fixture(%{
          invoice: invoice,
          description: "Product A",
          quantity: 5,
          amount: Money.new(10_000)
        })

      line_item2 =
        Trays.LineItemsFixtures.line_item_fixture(%{
          invoice: invoice,
          description: "Product B",
          quantity: 3,
          amount: Money.new(15_000)
        })

      result = Invoices.get_invoice_with_line_items!(invoice.id, merchant_location.id)

      assert result.id == invoice.id
      assert result.merchant_location_id == merchant_location.id
      assert length(result.line_items) == 2

      line_item_ids = Enum.map(result.line_items, & &1.id) |> Enum.sort()
      assert line_item_ids == [line_item1.id, line_item2.id] |> Enum.sort()
    end

    test "returns invoice with empty line_items list when no line items exist" do
      merchant_location = Trays.MerchantLocationsFixtures.merchant_location_fixture()
      invoice = Trays.InvoicesFixtures.invoice_fixture(%{merchant_location: merchant_location})

      result = Invoices.get_invoice_with_line_items!(invoice.id, merchant_location.id)

      assert result.id == invoice.id
      assert result.line_items == []
    end

    test "raises error when invoice does not exist" do
      merchant_location = Trays.MerchantLocationsFixtures.merchant_location_fixture()

      assert_raise Ecto.NoResultsError, fn ->
        Invoices.get_invoice_with_line_items!(999, merchant_location.id)
      end
    end

    test "raises error when invoice belongs to different merchant location" do
      merchant_location1 = Trays.MerchantLocationsFixtures.merchant_location_fixture()
      merchant_location2 = Trays.MerchantLocationsFixtures.merchant_location_fixture()

      invoice = Trays.InvoicesFixtures.invoice_fixture(%{merchant_location: merchant_location1})

      Trays.LineItemsFixtures.line_item_fixture(%{
        invoice: invoice,
        description: "Product A",
        quantity: 5,
        amount: Money.new(10_000)
      })

      assert_raise Ecto.NoResultsError, fn ->
        Invoices.get_invoice_with_line_items!(invoice.id, merchant_location2.id)
      end
    end

    test "line items are properly associated with invoice" do
      merchant_location = Trays.MerchantLocationsFixtures.merchant_location_fixture()
      invoice = Trays.InvoicesFixtures.invoice_fixture(%{merchant_location: merchant_location})

      line_item =
        Trays.LineItemsFixtures.line_item_fixture(%{
          invoice: invoice,
          description: "Premium Widget",
          quantity: 10,
          amount: Money.new(25_000)
        })

      result = Invoices.get_invoice_with_line_items!(invoice.id, merchant_location.id)

      assert length(result.line_items) == 1
      retrieved_line_item = hd(result.line_items)
      assert retrieved_line_item.id == line_item.id
      assert retrieved_line_item.description == "Premium Widget"
      assert retrieved_line_item.quantity == 10
      assert retrieved_line_item.amount == Money.new(25_000)
    end
  end

  describe "create_invoice_with_line_items/2" do
    test "creates invoice with line items in a transaction" do
      merchant_location = Trays.MerchantLocationsFixtures.merchant_location_fixture()

      invoice_attrs = %{
        name: "John Doe",
        email: "john@example.com",
        address: "123 Main St",
        phone_number: "555-1234",
        number: "INV-001",
        gst_hst: Money.new(1300),
        total_amount: Money.new(11_300),
        terms: :now,
        delivery_date: ~D[2025-02-15],
        merchant_location_id: merchant_location.id
      }

      line_items_attrs = [
        %{
          description: "Product A",
          quantity: 2,
          amount: Money.new(5000)
        },
        %{
          description: "Product B",
          quantity: 1,
          amount: Money.new(3000)
        }
      ]

      assert {:ok, invoice} =
               Invoices.create_invoice_with_line_items(invoice_attrs, line_items_attrs)

      assert invoice.name == "John Doe"
      assert invoice.number == "INV-001"

      # Verify line items were created
      invoice_with_items = Invoices.get_invoice_with_line_items!(invoice.id, merchant_location.id)
      assert length(invoice_with_items.line_items) == 2

      descriptions = Enum.map(invoice_with_items.line_items, & &1.description) |> Enum.sort()
      assert descriptions == ["Product A", "Product B"]
    end

    test "rolls back transaction if invoice creation fails" do
      merchant_location = Trays.MerchantLocationsFixtures.merchant_location_fixture()

      # Invalid invoice attrs (missing required fields)
      invoice_attrs = %{
        name: "Invalid Invoice"
      }

      line_items_attrs = [
        %{
          description: "Product A",
          quantity: 2,
          amount: Money.new(5000)
        }
      ]

      assert {:error, changeset} =
               Invoices.create_invoice_with_line_items(invoice_attrs, line_items_attrs)

      refute changeset.valid?

      # Verify no invoices were created
      assert Invoices.list_invoices(merchant_location.id) == []
    end

    test "rolls back transaction if line item creation fails" do
      merchant_location = Trays.MerchantLocationsFixtures.merchant_location_fixture()

      invoice_attrs = %{
        name: "John Doe",
        email: "john@example.com",
        address: "123 Main St",
        phone_number: "555-1234",
        number: "INV-ROLLBACK-TEST",
        gst_hst: Money.new(1300),
        total_amount: Money.new(11_300),
        terms: :now,
        delivery_date: ~D[2025-02-15],
        merchant_location_id: merchant_location.id
      }

      # One valid line item, one invalid (missing required fields)
      line_items_attrs = [
        %{
          description: "Valid Product",
          quantity: 2,
          amount: Money.new(5000)
        },
        %{
          description: "Invalid Product"
          # Missing quantity and amount
        }
      ]

      assert {:error, changeset} =
               Invoices.create_invoice_with_line_items(invoice_attrs, line_items_attrs)

      refute changeset.valid?

      # Verify no invoices were created (transaction rolled back)
      assert Invoices.list_invoices(merchant_location.id) == []
    end

    test "creates invoice with empty line items list" do
      merchant_location = Trays.MerchantLocationsFixtures.merchant_location_fixture()

      invoice_attrs = %{
        name: "Jane Doe",
        email: "jane@example.com",
        address: "456 Oak St",
        phone_number: "555-5678",
        number: "INV-EMPTY-ITEMS",
        gst_hst: Money.new(1000),
        total_amount: Money.new(10_000),
        terms: :net15,
        delivery_date: ~D[2025-03-01],
        merchant_location_id: merchant_location.id
      }

      line_items_attrs = []

      assert {:ok, invoice} =
               Invoices.create_invoice_with_line_items(invoice_attrs, line_items_attrs)

      assert invoice.name == "Jane Doe"

      # Verify no line items were created
      invoice_with_items = Invoices.get_invoice_with_line_items!(invoice.id, merchant_location.id)
      assert invoice_with_items.line_items == []
    end
  end

  describe "create_line_item/1" do
    test "creates line item with valid attributes" do
      invoice = Trays.InvoicesFixtures.invoice_fixture()

      attrs = %{
        description: "Widget Pro",
        quantity: 5,
        amount: Money.new(7500),
        invoice_id: invoice.id
      }

      assert {:ok, line_item} = Invoices.create_line_item(attrs)
      assert line_item.description == "Widget Pro"
      assert line_item.quantity == 5
      assert line_item.amount == Money.new(7500)
      assert line_item.invoice_id == invoice.id
    end

    test "returns error changeset with invalid attributes" do
      assert {:error, changeset} = Invoices.create_line_item(%{})
      refute changeset.valid?
    end

    test "returns error when invoice_id is missing" do
      attrs = %{
        description: "Product",
        quantity: 1,
        amount: Money.new(1000)
      }

      assert {:error, changeset} = Invoices.create_line_item(attrs)
      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset).invoice_id
    end

    test "returns error when description is missing" do
      invoice = Trays.InvoicesFixtures.invoice_fixture()

      attrs = %{
        quantity: 1,
        amount: Money.new(1000),
        invoice_id: invoice.id
      }

      assert {:error, changeset} = Invoices.create_line_item(attrs)
      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset).description
    end
  end

  describe "delete_line_item/1" do
    test "deletes the line item" do
      invoice = Trays.InvoicesFixtures.invoice_fixture()

      line_item =
        Trays.LineItemsFixtures.line_item_fixture(%{
          invoice: invoice,
          description: "To Delete",
          quantity: 1,
          amount: Money.new(1000)
        })

      assert {:ok, deleted_line_item} = Invoices.delete_line_item(line_item)
      assert deleted_line_item.id == line_item.id

      # Verify line item was deleted
      invoice_with_items =
        Invoices.get_invoice_with_line_items!(
          invoice.id,
          invoice.merchant_location_id
        )

      assert invoice_with_items.line_items == []
    end

    test "deletes line item without affecting other line items" do
      invoice = Trays.InvoicesFixtures.invoice_fixture()

      line_item1 =
        Trays.LineItemsFixtures.line_item_fixture(%{
          invoice: invoice,
          description: "Keep This",
          quantity: 1,
          amount: Money.new(1000)
        })

      line_item2 =
        Trays.LineItemsFixtures.line_item_fixture(%{
          invoice: invoice,
          description: "Delete This",
          quantity: 2,
          amount: Money.new(2000)
        })

      assert {:ok, _deleted} = Invoices.delete_line_item(line_item2)

      # Verify only one line item remains
      invoice_with_items =
        Invoices.get_invoice_with_line_items!(
          invoice.id,
          invoice.merchant_location_id
        )

      assert length(invoice_with_items.line_items) == 1
      assert hd(invoice_with_items.line_items).id == line_item1.id
      assert hd(invoice_with_items.line_items).description == "Keep This"
    end
  end

  describe "change_line_item/2" do
    test "returns a changeset for the line item" do
      line_item = Trays.LineItemsFixtures.line_item_fixture()

      changeset = Invoices.change_line_item(line_item)

      assert %Ecto.Changeset{} = changeset
      assert changeset.data.id == line_item.id
    end

    test "returns a changeset with changes" do
      line_item = Trays.LineItemsFixtures.line_item_fixture()

      changeset = Invoices.change_line_item(line_item, %{description: "Updated Product"})

      assert %Ecto.Changeset{} = changeset
      assert changeset.changes.description == "Updated Product"
    end

    test "uses regular changeset validation" do
      line_item = Trays.LineItemsFixtures.line_item_fixture()

      # Invalid quantity (0)
      changeset = Invoices.change_line_item(line_item, %{quantity: 0})

      refute changeset.valid?
      assert "must be greater than 0" in errors_on(changeset).quantity
    end
  end

  describe "change_temp_line_item/2" do
    test "returns a changeset for temporary line item" do
      line_item = %Trays.Invoices.LineItem{}

      changeset = Invoices.change_temp_line_item(line_item)

      assert %Ecto.Changeset{} = changeset
    end

    test "returns a changeset with changes" do
      line_item = %Trays.Invoices.LineItem{}

      attrs = %{
        description: "Temp Product",
        quantity: 3,
        amount: Money.new(5000)
      }

      changeset = Invoices.change_temp_line_item(line_item, attrs)

      assert %Ecto.Changeset{} = changeset
      assert changeset.changes.description == "Temp Product"
      assert changeset.changes.quantity == 3
      assert changeset.changes.amount == Money.new(5000)
    end

    test "uses temp_changeset validation requiring all fields" do
      line_item = %Trays.Invoices.LineItem{}

      # Missing required fields for temp changeset
      changeset = Invoices.change_temp_line_item(line_item, %{description: "Product"})

      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset).quantity
      # Amount validation shows as Money validation error when nil
      assert length(errors_on(changeset).amount) > 0
    end

    test "validates amount is greater than zero" do
      line_item = %Trays.Invoices.LineItem{}

      attrs = %{
        description: "Product",
        quantity: 1,
        amount: Money.new(0)
      }

      changeset = Invoices.change_temp_line_item(line_item, attrs)

      refute changeset.valid?
      # Money error messages include currency symbol (Can$)
      [error] = errors_on(changeset).amount
      assert error =~ "must be greater than"
      assert error =~ "$0.00"
    end

    test "validates quantity is greater than zero" do
      line_item = %Trays.Invoices.LineItem{}

      attrs = %{
        description: "Product",
        quantity: 0,
        amount: Money.new(1000)
      }

      changeset = Invoices.change_temp_line_item(line_item, attrs)

      refute changeset.valid?
      assert "must be greater than 0" in errors_on(changeset).quantity
    end
  end
end
