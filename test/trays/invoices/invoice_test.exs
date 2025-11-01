defmodule Trays.Invoices.InvoiceTest do
  use Trays.DataCase

  alias Trays.Invoices.Invoice

  describe "changeset/2" do
    test "valid changeset with all required fields" do
      merchant_location = Trays.MerchantLocationsFixtures.merchant_location_fixture()

      attrs = %{
        name: "John Doe",
        email: "john@example.com",
        address: "123 Main St",
        phone_number: "555-1234",
        number: "INV-001",
        gst_hst: Money.new(1300),
        total_amount: Money.new(10_000),
        terms: :net30,
        delivery_date: ~D[2025-01-01],
        merchant_location_id: merchant_location.id
      }

      changeset = Invoice.changeset(%Invoice{}, attrs)
      assert changeset.valid?
    end

    test "invalid changeset when required fields are missing" do
      changeset = Invoice.changeset(%Invoice{}, %{})
      refute changeset.valid?

      assert errors_on(changeset) == %{
               name: ["can't be blank"],
               email: ["can't be blank"],
               address: ["can't be blank"],
               phone_number: ["can't be blank"],
               number: ["can't be blank"],
               gst_hst: ["can't be blank"],
               total_amount: ["can't be blank"],
               terms: ["can't be blank"],
               delivery_date: ["can't be blank"],
               merchant_location_id: ["can't be blank"]
             }
    end

    test "invalid email format" do
      merchant_location = Trays.MerchantLocationsFixtures.merchant_location_fixture()

      attrs = %{
        name: "John Doe",
        email: "invalid-email",
        address: "123 Main St",
        phone_number: "555-1234",
        number: "INV-001",
        gst_hst: Money.new(1300),
        total_amount: Money.new(10_000),
        terms: :net30,
        delivery_date: ~D[2025-01-01],
        merchant_location_id: merchant_location.id
      }

      changeset = Invoice.changeset(%Invoice{}, attrs)
      refute changeset.valid?
      assert "must be a valid email" in errors_on(changeset).email
    end

    test "gst_hst cannot be negative" do
      merchant_location = Trays.MerchantLocationsFixtures.merchant_location_fixture()

      attrs = %{
        name: "John Doe",
        email: "john@example.com",
        address: "123 Main St",
        phone_number: "555-1234",
        number: "INV-001",
        gst_hst: Money.new(-100),
        total_amount: Money.new(10_000),
        terms: :net30,
        delivery_date: ~D[2025-01-01],
        merchant_location_id: merchant_location.id
      }

      changeset = Invoice.changeset(%Invoice{}, attrs)
      refute changeset.valid?
      assert "must be greater than or equal to Can$0.00" in errors_on(changeset).gst_hst
    end

    test "total_amount must be greater than 0" do
      merchant_location = Trays.MerchantLocationsFixtures.merchant_location_fixture()

      attrs = %{
        name: "John Doe",
        email: "john@example.com",
        address: "123 Main St",
        phone_number: "555-1234",
        number: "INV-001",
        gst_hst: Money.new(0),
        total_amount: Money.new(0),
        terms: :net30,
        delivery_date: ~D[2025-01-01],
        merchant_location_id: merchant_location.id
      }

      changeset = Invoice.changeset(%Invoice{}, attrs)
      refute changeset.valid?
      assert "must be greater than Can$0.00" in errors_on(changeset).total_amount
    end

    test "accepts valid terms values" do
      merchant_location = Trays.MerchantLocationsFixtures.merchant_location_fixture()

      base_attrs = %{
        name: "John Doe",
        email: "john@example.com",
        address: "123 Main St",
        phone_number: "555-1234",
        number: "INV-001",
        gst_hst: Money.new(1300),
        total_amount: Money.new(10_000),
        delivery_date: ~D[2025-01-01],
        merchant_location_id: merchant_location.id
      }

      for terms <- [:now, :net15, :net30] do
        changeset = Invoice.changeset(%Invoice{}, Map.put(base_attrs, :terms, terms))
        assert changeset.valid?, "Expected terms #{terms} to be valid"
      end
    end

    test "accepts valid status values" do
      merchant_location = Trays.MerchantLocationsFixtures.merchant_location_fixture()

      base_attrs = %{
        name: "John Doe",
        email: "john@example.com",
        address: "123 Main St",
        phone_number: "555-1234",
        number: "INV-001",
        gst_hst: Money.new(1300),
        total_amount: Money.new(10_000),
        terms: :net30,
        delivery_date: ~D[2025-01-01],
        merchant_location_id: merchant_location.id
      }

      for status <- [:outstanding, :paid] do
        changeset = Invoice.changeset(%Invoice{}, Map.put(base_attrs, :status, status))
        assert changeset.valid?, "Expected status #{status} to be valid"
      end
    end

    test "status defaults to outstanding" do
      merchant_location = Trays.MerchantLocationsFixtures.merchant_location_fixture()

      attrs = %{
        name: "John Doe",
        email: "john@example.com",
        address: "123 Main St",
        phone_number: "555-1234",
        number: "INV-001",
        gst_hst: Money.new(1300),
        total_amount: Money.new(10_000),
        terms: :net30,
        delivery_date: ~D[2025-01-01],
        merchant_location_id: merchant_location.id
      }

      {:ok, invoice} = %Invoice{} |> Invoice.changeset(attrs) |> Repo.insert()
      assert invoice.status == :outstanding
    end
  end
end
