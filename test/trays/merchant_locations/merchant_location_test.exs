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

  describe "changeset/2 required fields" do
    setup do
      merchant = Trays.MerchantsFixtures.merchant_fixture()
      %{merchant: merchant}
    end

    test "valid changeset with all required fields", %{merchant: merchant} do
      attrs = %{
        street1: "123 Main St",
        city: "Toronto",
        province: "ON",
        postal_code: "M5V 1A1",
        country: "Canada",
        merchant_id: merchant.id
      }

      changeset = MerchantLocation.changeset(%MerchantLocation{}, attrs)
      assert changeset.valid?
    end

    test "invalid when street1 is missing", %{merchant: merchant} do
      attrs = %{
        city: "Toronto",
        province: "ON",
        postal_code: "M5V 1A1",
        country: "Canada",
        merchant_id: merchant.id
      }

      changeset = MerchantLocation.changeset(%MerchantLocation{}, attrs)
      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset).street1
    end

    test "invalid when city is missing", %{merchant: merchant} do
      attrs = %{
        street1: "123 Main St",
        province: "ON",
        postal_code: "M5V 1A1",
        country: "Canada",
        merchant_id: merchant.id
      }

      changeset = MerchantLocation.changeset(%MerchantLocation{}, attrs)
      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset).city
    end

    test "invalid when province is missing", %{merchant: merchant} do
      attrs = %{
        street1: "123 Main St",
        city: "Toronto",
        postal_code: "M5V 1A1",
        country: "Canada",
        merchant_id: merchant.id
      }

      changeset = MerchantLocation.changeset(%MerchantLocation{}, attrs)
      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset).province
    end

    test "invalid when postal_code is missing", %{merchant: merchant} do
      attrs = %{
        street1: "123 Main St",
        city: "Toronto",
        province: "ON",
        country: "Canada",
        merchant_id: merchant.id
      }

      changeset = MerchantLocation.changeset(%MerchantLocation{}, attrs)
      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset).postal_code
    end

    test "invalid when country is missing", %{merchant: merchant} do
      attrs = %{
        street1: "123 Main St",
        city: "Toronto",
        province: "ON",
        postal_code: "M5V 1A1",
        merchant_id: merchant.id
      }

      changeset = MerchantLocation.changeset(%MerchantLocation{}, attrs)
      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset).country
    end

    test "invalid when merchant_id is missing" do
      attrs = %{
        street1: "123 Main St",
        city: "Toronto",
        province: "ON",
        postal_code: "M5V 1A1",
        country: "Canada"
      }

      changeset = MerchantLocation.changeset(%MerchantLocation{}, attrs)
      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset).merchant_id
    end

    test "invalid when all required fields are missing" do
      changeset = MerchantLocation.changeset(%MerchantLocation{}, %{})
      refute changeset.valid?

      errors = errors_on(changeset)
      assert "can't be blank" in errors.street1
      assert "can't be blank" in errors.city
      assert "can't be blank" in errors.province
      assert "can't be blank" in errors.postal_code
      assert "can't be blank" in errors.country
      assert "can't be blank" in errors.merchant_id
    end
  end

  describe "changeset/2 optional fields" do
    setup do
      merchant = Trays.MerchantsFixtures.merchant_fixture()
      %{merchant: merchant}
    end

    test "street2 is optional", %{merchant: merchant} do
      attrs = %{
        street1: "123 Main St",
        city: "Toronto",
        province: "ON",
        postal_code: "M5V 1A1",
        country: "Canada",
        merchant_id: merchant.id
      }

      changeset = MerchantLocation.changeset(%MerchantLocation{}, attrs)
      assert changeset.valid?
      refute Map.has_key?(changeset.changes, :street2)
    end

    test "accepts street2 when provided", %{merchant: merchant} do
      attrs = %{
        street1: "123 Main St",
        street2: "Suite 200",
        city: "Toronto",
        province: "ON",
        postal_code: "M5V 1A1",
        country: "Canada",
        merchant_id: merchant.id
      }

      changeset = MerchantLocation.changeset(%MerchantLocation{}, attrs)
      assert changeset.valid?
      assert changeset.changes.street2 == "Suite 200"
    end

    test "user_id is required by database", %{merchant: merchant} do
      attrs = %{
        street1: "123 Main St",
        city: "Toronto",
        province: "ON",
        postal_code: "M5V 1A1",
        country: "Canada",
        merchant_id: merchant.id
      }

      changeset = MerchantLocation.changeset(%MerchantLocation{}, attrs)
      # Changeset is valid but database will reject it
      assert changeset.valid?

      # Database has NOT NULL constraint on user_id
      assert_raise Postgrex.Error, fn ->
        Repo.insert(changeset)
      end
    end

    test "accepts user_id when provided", %{merchant: merchant} do
      user = Trays.AccountsFixtures.user_fixture(%{type: :merchant})

      attrs = %{
        street1: "123 Main St",
        city: "Toronto",
        province: "ON",
        postal_code: "M5V 1A1",
        country: "Canada",
        merchant_id: merchant.id,
        user_id: user.id
      }

      changeset = MerchantLocation.changeset(%MerchantLocation{}, attrs)
      assert changeset.valid?
      assert changeset.changes.user_id == user.id
    end
  end

  describe "changeset/2 foreign key constraints" do
    test "foreign key constraint when merchant does not exist" do
      user = Trays.AccountsFixtures.user_fixture(%{type: :merchant})

      attrs = %{
        street1: "123 Main St",
        city: "Toronto",
        province: "ON",
        postal_code: "M5V 1A1",
        country: "Canada",
        merchant_id: 999_999,
        user_id: user.id
      }

      changeset = MerchantLocation.changeset(%MerchantLocation{}, attrs)
      assert changeset.valid?

      {:error, changeset} = Repo.insert(changeset)
      assert "does not exist" in errors_on(changeset).merchant_id
    end

    test "foreign key constraint when user does not exist" do
      merchant = Trays.MerchantsFixtures.merchant_fixture()

      attrs = %{
        street1: "123 Main St",
        city: "Toronto",
        province: "ON",
        postal_code: "M5V 1A1",
        country: "Canada",
        merchant_id: merchant.id,
        user_id: 999_999
      }

      changeset = MerchantLocation.changeset(%MerchantLocation{}, attrs)
      assert changeset.valid?

      {:error, changeset} = Repo.insert(changeset)
      assert "does not exist" in errors_on(changeset).user_id
    end
  end

  describe "changeset/2 updating" do
    test "can update street1" do
      location = Trays.MerchantLocationsFixtures.merchant_location_fixture()

      attrs = %{street1: "456 New St"}
      changeset = MerchantLocation.changeset(location, attrs)

      assert changeset.valid?
      {:ok, updated} = Repo.update(changeset)
      assert updated.street1 == "456 New St"
    end

    test "can update city" do
      location = Trays.MerchantLocationsFixtures.merchant_location_fixture()

      attrs = %{city: "Vancouver"}
      changeset = MerchantLocation.changeset(location, attrs)

      assert changeset.valid?
      {:ok, updated} = Repo.update(changeset)
      assert updated.city == "Vancouver"
    end

    test "can update province" do
      location = Trays.MerchantLocationsFixtures.merchant_location_fixture()

      attrs = %{province: "BC"}
      changeset = MerchantLocation.changeset(location, attrs)

      assert changeset.valid?
      {:ok, updated} = Repo.update(changeset)
      assert updated.province == "BC"
    end

    test "can update postal_code" do
      location = Trays.MerchantLocationsFixtures.merchant_location_fixture()

      attrs = %{postal_code: "V6B 1A1"}
      changeset = MerchantLocation.changeset(location, attrs)

      assert changeset.valid?
      {:ok, updated} = Repo.update(changeset)
      assert updated.postal_code == "V6B 1A1"
    end

    test "can update country" do
      location = Trays.MerchantLocationsFixtures.merchant_location_fixture()

      attrs = %{country: "USA"}
      changeset = MerchantLocation.changeset(location, attrs)

      assert changeset.valid?
      {:ok, updated} = Repo.update(changeset)
      assert updated.country == "USA"
    end

    test "can update email" do
      location = Trays.MerchantLocationsFixtures.merchant_location_fixture()

      attrs = %{email: "newemail@example.com"}
      changeset = MerchantLocation.changeset(location, attrs)

      assert changeset.valid?
      {:ok, updated} = Repo.update(changeset)
      assert updated.email == "newemail@example.com"
    end

    test "can update phone_number" do
      location = Trays.MerchantLocationsFixtures.merchant_location_fixture()

      attrs = %{phone_number: "555-9999"}
      changeset = MerchantLocation.changeset(location, attrs)

      assert changeset.valid?
      {:ok, updated} = Repo.update(changeset)
      assert updated.phone_number == "555-9999"
    end

    test "can update street2" do
      location = Trays.MerchantLocationsFixtures.merchant_location_fixture()

      attrs = %{street2: "Apt 5B"}
      changeset = MerchantLocation.changeset(location, attrs)

      assert changeset.valid?
      {:ok, updated} = Repo.update(changeset)
      assert updated.street2 == "Apt 5B"
    end

    test "validates email format on update" do
      location = Trays.MerchantLocationsFixtures.merchant_location_fixture()

      attrs = %{email: "invalid-email"}
      changeset = MerchantLocation.changeset(location, attrs)

      refute changeset.valid?
      assert "must be a valid email" in errors_on(changeset).email
    end
  end

  describe "delete_changeset/2" do
    test "allows deletion when no bank account exists" do
      location = Trays.MerchantLocationsFixtures.merchant_location_fixture()

      changeset = MerchantLocation.delete_changeset(location)
      assert changeset.valid?

      {:ok, _deleted} = Repo.delete(changeset)
    end

    test "prevents deletion when bank account exists" do
      location = Trays.MerchantLocationsFixtures.merchant_location_fixture()

      _bank_account =
        Trays.BankAccountsFixtures.bank_account_fixture(%{merchant_location: location})

      changeset = MerchantLocation.delete_changeset(location)
      assert changeset.valid?

      {:error, changeset} = Repo.delete(changeset)

      assert "cannot delete location with associated bank account" in errors_on(changeset).bank_account
    end
  end

  describe "associations" do
    test "belongs to merchant" do
      location = Trays.MerchantLocationsFixtures.merchant_location_fixture()
      location = Repo.preload(location, :merchant)

      assert location.merchant != nil
      assert location.merchant.id == location.merchant_id
    end

    test "belongs to manager (user)" do
      user = Trays.AccountsFixtures.user_fixture(%{type: :merchant})
      location = Trays.MerchantLocationsFixtures.merchant_location_fixture(%{user: user})
      location = Repo.preload(location, :manager)

      assert location.manager != nil
      assert location.manager.id == user.id
      assert location.user_id == user.id
    end

    test "has one bank_account" do
      location = Trays.MerchantLocationsFixtures.merchant_location_fixture()

      bank_account =
        Trays.BankAccountsFixtures.bank_account_fixture(%{merchant_location: location})

      location = Repo.preload(location, :bank_account)

      assert location.bank_account != nil
      assert location.bank_account.id == bank_account.id
    end

    test "manager is required" do
      location = Trays.MerchantLocationsFixtures.merchant_location_fixture()
      location = Repo.preload(location, :manager)

      # user_id is NOT NULL in the database, so it must always have a value
      assert location.user_id != nil
      assert location.manager != nil
    end
  end

  describe "data persistence" do
    test "creates merchant location with all fields" do
      merchant = Trays.MerchantsFixtures.merchant_fixture()
      user = Trays.AccountsFixtures.user_fixture(%{type: :merchant})

      attrs = %{
        street1: "123 Main St",
        street2: "Suite 100",
        city: "Toronto",
        province: "ON",
        postal_code: "M5V 1A1",
        country: "Canada",
        email: "location@example.com",
        phone_number: "555-1234",
        merchant_id: merchant.id,
        user_id: user.id
      }

      changeset = MerchantLocation.changeset(%MerchantLocation{}, attrs)
      {:ok, location} = Repo.insert(changeset)

      assert location.street1 == "123 Main St"
      assert location.street2 == "Suite 100"
      assert location.city == "Toronto"
      assert location.province == "ON"
      assert location.postal_code == "M5V 1A1"
      assert location.country == "Canada"
      assert location.email == "location@example.com"
      assert location.phone_number == "555-1234"
      assert location.merchant_id == merchant.id
      assert location.user_id == user.id
      assert location.inserted_at != nil
      assert location.updated_at != nil
    end

    test "creates merchant location with minimum required fields" do
      merchant = Trays.MerchantsFixtures.merchant_fixture()
      user = Trays.AccountsFixtures.user_fixture(%{type: :merchant})

      attrs = %{
        street1: "123 Main St",
        city: "Toronto",
        province: "ON",
        postal_code: "M5V 1A1",
        country: "Canada",
        merchant_id: merchant.id,
        user_id: user.id
      }

      changeset = MerchantLocation.changeset(%MerchantLocation{}, attrs)
      {:ok, location} = Repo.insert(changeset)

      assert location.street1 == "123 Main St"
      assert location.street2 == nil
      assert location.city == "Toronto"
      assert location.province == "ON"
      assert location.postal_code == "M5V 1A1"
      assert location.country == "Canada"
      assert location.email == nil
      assert location.phone_number == nil
      assert location.merchant_id == merchant.id
      assert location.user_id == user.id
    end
  end
end
