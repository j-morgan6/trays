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
  end
end
