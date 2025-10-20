defmodule Trays.MerchantLocations.MerchantLocationTest do
  use Trays.DataCase

  alias Trays.MerchantLocations.MerchantLocation

  describe "changeset/2 with email and phone_number" do
    setup do
      merchant = Trays.MerchantsFixtures.merchant_fixture()
      %{merchant: merchant}
    end

    test "accepts valid email", %{merchant: merchant} do
      attrs = %{
        street1: "123 Main St",
        city: "Toronto",
        province: "ON",
        postal_code: "M5V 1A1",
        country: "Canada",
        merchant_id: merchant.id,
        email: "location@example.com",
        phone_number: "555-1234"
      }

      changeset = MerchantLocation.changeset(%MerchantLocation{}, attrs)
      assert changeset.valid?
    end

    test "email is optional", %{merchant: merchant} do
      attrs = %{
        street1: "123 Main St",
        city: "Toronto",
        province: "ON",
        postal_code: "M5V 1A1",
        country: "Canada",
        merchant_id: merchant.id,
        phone_number: "555-1234"
      }

      changeset = MerchantLocation.changeset(%MerchantLocation{}, attrs)
      assert changeset.valid?
    end

    test "phone_number is optional", %{merchant: merchant} do
      attrs = %{
        street1: "123 Main St",
        city: "Toronto",
        province: "ON",
        postal_code: "M5V 1A1",
        country: "Canada",
        merchant_id: merchant.id,
        email: "location@example.com"
      }

      changeset = MerchantLocation.changeset(%MerchantLocation{}, attrs)
      assert changeset.valid?
    end

    test "validates email format", %{merchant: merchant} do
      attrs = %{
        street1: "123 Main St",
        city: "Toronto",
        province: "ON",
        postal_code: "M5V 1A1",
        country: "Canada",
        merchant_id: merchant.id,
        email: "invalid-email"
      }

      changeset = MerchantLocation.changeset(%MerchantLocation{}, attrs)
      refute changeset.valid?
      assert "must be a valid email" in errors_on(changeset).email
    end

    test "accepts valid email formats", %{merchant: merchant} do
      base_attrs = %{
        street1: "123 Main St",
        city: "Toronto",
        province: "ON",
        postal_code: "M5V 1A1",
        country: "Canada",
        merchant_id: merchant.id
      }

      valid_emails = [
        "test@example.com",
        "user+tag@example.co.uk",
        "first.last@example.com",
        "user123@test-domain.com"
      ]

      for email <- valid_emails do
        changeset =
          MerchantLocation.changeset(%MerchantLocation{}, Map.put(base_attrs, :email, email))

        assert changeset.valid?, "Expected #{email} to be valid"
      end
    end

    test "rejects invalid email formats", %{merchant: merchant} do
      base_attrs = %{
        street1: "123 Main St",
        city: "Toronto",
        province: "ON",
        postal_code: "M5V 1A1",
        country: "Canada",
        merchant_id: merchant.id
      }

      invalid_emails = [
        "not-an-email",
        "@example.com",
        "user@",
        "user @example.com",
        "user@example .com"
      ]

      for email <- invalid_emails do
        changeset =
          MerchantLocation.changeset(%MerchantLocation{}, Map.put(base_attrs, :email, email))

        refute changeset.valid?, "Expected #{email} to be invalid"
        assert "must be a valid email" in errors_on(changeset).email
      end
    end
  end
end
