defmodule Trays.MerchantsTest do
  use Trays.DataCase

  alias Trays.Merchants

  describe "merchants authorization" do
    setup do
      user1 = Trays.AccountsFixtures.user_fixture(%{type: :merchant})
      user2 = Trays.AccountsFixtures.user_fixture(%{email: "other@example.com", type: :merchant})

      merchant1 = Trays.MerchantsFixtures.merchant_fixture(%{user: user1})
      merchant2 = Trays.MerchantsFixtures.merchant_fixture(%{user: user2})

      %{user1: user1, user2: user2, merchant1: merchant1, merchant2: merchant2}
    end

    test "list_merchants/1 only returns merchants belonging to the user", %{
      user1: user1,
      user2: user2,
      merchant1: merchant1,
      merchant2: merchant2
    } do
      user1_merchants = Merchants.list_merchants(user1.id)
      user2_merchants = Merchants.list_merchants(user2.id)

      assert length(user1_merchants) == 1
      assert length(user2_merchants) == 1

      assert hd(user1_merchants).id == merchant1.id
      assert hd(user2_merchants).id == merchant2.id

      refute Enum.any?(user1_merchants, fn m -> m.id == merchant2.id end)
      refute Enum.any?(user2_merchants, fn m -> m.id == merchant1.id end)
    end

    test "get_merchant!/2 returns merchant when it belongs to the user", %{
      user1: user1,
      merchant1: merchant1
    } do
      fetched_merchant = Merchants.get_merchant!(merchant1.id, user1.id)
      assert fetched_merchant.id == merchant1.id
    end

    test "get_merchant!/2 raises when merchant doesn't belong to user", %{
      user1: user1,
      merchant2: merchant2
    } do
      assert_raise Ecto.NoResultsError, fn ->
        Merchants.get_merchant!(merchant2.id, user1.id)
      end
    end

    test "get_merchant!/2 raises when merchant doesn't exist", %{user1: user1} do
      assert_raise Ecto.NoResultsError, fn ->
        Merchants.get_merchant!(999_999, user1.id)
      end
    end

    test "create_merchant/1 creates merchant with user_id" do
      new_user =
        Trays.AccountsFixtures.user_fixture(%{email: "newuser@example.com", type: :merchant})

      attrs = %{
        name: "New Merchant",
        description: "New merchant description",
        user_id: new_user.id
      }

      assert {:ok, merchant} = Merchants.create_merchant(attrs)
      assert merchant.user_id == new_user.id
      assert merchant.name == "New Merchant"
    end

    test "get_merchants_for_select/1 only returns user's merchants", %{
      user1: user1,
      user2: user2,
      merchant1: merchant1,
      merchant2: merchant2
    } do
      user1_options = Merchants.get_merchants_for_select(user1.id)
      user2_options = Merchants.get_merchants_for_select(user2.id)

      assert length(user1_options) == 1
      assert length(user2_options) == 1

      assert {merchant1.name, merchant1.id} in user1_options
      assert {merchant2.name, merchant2.id} in user2_options

      refute {merchant2.name, merchant2.id} in user1_options
      refute {merchant1.name, merchant1.id} in user2_options
    end

    test "get_merchants_for_select/1 returns merchant name and id" do
      user = Trays.AccountsFixtures.user_fixture(%{email: "user1@test.com", type: :merchant})

      merchant =
        Trays.MerchantsFixtures.merchant_fixture(%{
          user: user,
          name: "Test Merchant",
          description: "A test merchant"
        })

      result = Merchants.get_merchants_for_select(user.id)

      assert result == [{"Test Merchant", merchant.id}]
    end
  end

  describe "create_merchant/1" do
    test "creates merchant with valid attributes" do
      user = Trays.AccountsFixtures.user_fixture(%{type: :merchant})

      attrs = %{
        name: "Test Business",
        description: "A test business description",
        user_id: user.id
      }

      assert {:ok, merchant} = Merchants.create_merchant(attrs)
      assert merchant.name == "Test Business"
      assert merchant.description == "A test business description"
      assert merchant.user_id == user.id
    end

    test "returns error changeset with invalid attributes" do
      assert {:error, changeset} = Merchants.create_merchant(%{})
      assert %{name: ["can't be blank"]} = errors_on(changeset)
      assert %{description: ["can't be blank"]} = errors_on(changeset)
      assert %{user_id: ["can't be blank"]} = errors_on(changeset)
    end

    test "returns error changeset when name is missing" do
      user = Trays.AccountsFixtures.user_fixture(%{type: :merchant})

      attrs = %{
        description: "A test business",
        user_id: user.id
      }

      assert {:error, changeset} = Merchants.create_merchant(attrs)
      assert %{name: ["can't be blank"]} = errors_on(changeset)
    end

    test "returns error changeset when user_id is invalid" do
      attrs = %{
        name: "Test Business",
        description: "A test business",
        user_id: 999_999
      }

      assert {:error, changeset} = Merchants.create_merchant(attrs)
      assert %{user_id: ["does not exist"]} = errors_on(changeset)
    end
  end

  describe "update_merchant/2" do
    test "updates merchant with valid attributes" do
      user = Trays.AccountsFixtures.user_fixture(%{type: :merchant})
      merchant = Trays.MerchantsFixtures.merchant_fixture(%{user: user})

      attrs = %{
        name: "Updated Name",
        description: "Updated description"
      }

      assert {:ok, updated_merchant} = Merchants.update_merchant(merchant, attrs)
      assert updated_merchant.name == "Updated Name"
      assert updated_merchant.description == "Updated description"
      assert updated_merchant.id == merchant.id
    end

    test "returns error changeset with invalid attributes" do
      user = Trays.AccountsFixtures.user_fixture(%{type: :merchant})
      merchant = Trays.MerchantsFixtures.merchant_fixture(%{user: user})

      attrs = %{name: nil}

      assert {:error, changeset} = Merchants.update_merchant(merchant, attrs)
      assert %{name: ["can't be blank"]} = errors_on(changeset)
    end

    test "doesn't change other fields when updating specific field" do
      user = Trays.AccountsFixtures.user_fixture(%{type: :merchant})
      merchant = Trays.MerchantsFixtures.merchant_fixture(%{user: user, name: "Original"})

      attrs = %{description: "New description"}

      assert {:ok, updated_merchant} = Merchants.update_merchant(merchant, attrs)
      assert updated_merchant.name == "Original"
      assert updated_merchant.description == "New description"
    end
  end

  describe "delete_merchant/1" do
    test "deletes the merchant" do
      user = Trays.AccountsFixtures.user_fixture(%{type: :merchant})
      merchant = Trays.MerchantsFixtures.merchant_fixture(%{user: user})

      assert {:ok, deleted_merchant} = Merchants.delete_merchant(merchant)
      assert deleted_merchant.id == merchant.id

      assert_raise Ecto.NoResultsError, fn ->
        Merchants.get_merchant!(merchant.id, user.id)
      end
    end

    test "merchant cannot be retrieved after deletion" do
      user = Trays.AccountsFixtures.user_fixture(%{type: :merchant})
      merchant = Trays.MerchantsFixtures.merchant_fixture(%{user: user})

      Merchants.delete_merchant(merchant)

      assert Merchants.list_merchants(user.id) == []
    end
  end

  describe "change_merchant/2" do
    test "returns a changeset" do
      merchant = %Trays.Merchants.Merchant{}
      changeset = Merchants.change_merchant(merchant)
      assert %Ecto.Changeset{} = changeset
    end

    test "returns changeset with changes" do
      user = Trays.AccountsFixtures.user_fixture(%{type: :merchant})
      merchant = Trays.MerchantsFixtures.merchant_fixture(%{user: user})

      attrs = %{name: "New Name"}
      changeset = Merchants.change_merchant(merchant, attrs)

      assert changeset.changes.name == "New Name"
    end
  end

  describe "get_or_create_default_merchant/1" do
    test "creates default merchant when user has no merchants" do
      user = Trays.AccountsFixtures.user_fixture(%{type: :merchant})

      merchant = Merchants.get_or_create_default_merchant(user.id)

      assert merchant.user_id == user.id
      assert merchant.name == "Default Merchant"
      assert merchant.description == "Default merchant account"
    end

    test "returns existing merchant when user already has one" do
      user = Trays.AccountsFixtures.user_fixture(%{type: :merchant})

      existing_merchant =
        Trays.MerchantsFixtures.merchant_fixture(%{user: user, name: "Existing"})

      merchant = Merchants.get_or_create_default_merchant(user.id)

      assert merchant.id == existing_merchant.id
      assert merchant.name == "Existing"
      refute merchant.name == "Default Merchant"
    end
  end

  describe "list_merchants_with_location_counts/1" do
    test "returns merchants with zero locations" do
      user = Trays.AccountsFixtures.user_fixture(%{type: :merchant})
      merchant = Trays.MerchantsFixtures.merchant_fixture(%{user: user})

      results = Merchants.list_merchants_with_location_counts(user.id)

      assert length(results) == 1
      assert [%{merchant: returned_merchant, location_count: count}] = results
      assert returned_merchant.id == merchant.id
      assert count == 0
    end

    test "returns merchants with correct location counts" do
      user = Trays.AccountsFixtures.user_fixture(%{type: :merchant})
      merchant = Trays.MerchantsFixtures.merchant_fixture(%{user: user})

      # Create 3 locations for this merchant
      Trays.MerchantLocationsFixtures.merchant_location_fixture(%{user: user, merchant: merchant})

      Trays.MerchantLocationsFixtures.merchant_location_fixture(%{
        user: user,
        merchant: merchant,
        city: "Vancouver"
      })

      Trays.MerchantLocationsFixtures.merchant_location_fixture(%{
        user: user,
        merchant: merchant,
        city: "Montreal"
      })

      results = Merchants.list_merchants_with_location_counts(user.id)

      assert length(results) == 1
      assert [%{merchant: returned_merchant, location_count: count}] = results
      assert returned_merchant.id == merchant.id
      assert count == 3
    end

    test "only returns merchants for specific user" do
      user1 = Trays.AccountsFixtures.user_fixture(%{type: :merchant})
      user2 = Trays.AccountsFixtures.user_fixture(%{email: "other@example.com", type: :merchant})

      merchant1 = Trays.MerchantsFixtures.merchant_fixture(%{user: user1})
      merchant2 = Trays.MerchantsFixtures.merchant_fixture(%{user: user2})

      Trays.MerchantLocationsFixtures.merchant_location_fixture(%{
        user: user1,
        merchant: merchant1
      })

      Trays.MerchantLocationsFixtures.merchant_location_fixture(%{
        user: user2,
        merchant: merchant2
      })

      user1_results = Merchants.list_merchants_with_location_counts(user1.id)
      user2_results = Merchants.list_merchants_with_location_counts(user2.id)

      assert length(user1_results) == 1
      assert length(user2_results) == 1

      assert hd(user1_results).merchant.id == merchant1.id
      assert hd(user2_results).merchant.id == merchant2.id
    end

    test "handles multiple users each with their own merchant" do
      user1 = Trays.AccountsFixtures.user_fixture(%{type: :merchant, email: "user1@example.com"})
      user2 = Trays.AccountsFixtures.user_fixture(%{type: :merchant, email: "user2@example.com"})
      merchant1 = Trays.MerchantsFixtures.merchant_fixture(%{user: user1, name: "User1 Merchant"})
      merchant2 = Trays.MerchantsFixtures.merchant_fixture(%{user: user2, name: "User2 Merchant"})

      # merchant1 has 2 locations
      Trays.MerchantLocationsFixtures.merchant_location_fixture(%{
        user: user1,
        merchant: merchant1
      })

      Trays.MerchantLocationsFixtures.merchant_location_fixture(%{
        user: user1,
        merchant: merchant1,
        city: "Vancouver"
      })

      # merchant2 has 1 location
      Trays.MerchantLocationsFixtures.merchant_location_fixture(%{
        user: user2,
        merchant: merchant2
      })

      user1_results = Merchants.list_merchants_with_location_counts(user1.id)
      user2_results = Merchants.list_merchants_with_location_counts(user2.id)

      assert length(user1_results) == 1
      assert length(user2_results) == 1

      assert hd(user1_results).location_count == 2
      assert hd(user2_results).location_count == 1
    end
  end
end
