defmodule Trays.MerchantLocationsTest do
  use Trays.DataCase

  alias Trays.MerchantLocations

  describe "merchant_locations authorization" do
    setup do
      user1 = Trays.AccountsFixtures.user_fixture(%{type: :merchant})
      user2 = Trays.AccountsFixtures.user_fixture(%{email: "other@example.com", type: :merchant})

      merchant1 = Trays.MerchantsFixtures.merchant_fixture(%{user: user1})
      merchant2 = Trays.MerchantsFixtures.merchant_fixture(%{user: user2})

      location1 =
        Trays.MerchantLocationsFixtures.merchant_location_fixture(%{
          user: user1,
          merchant: merchant1
        })

      location2 =
        Trays.MerchantLocationsFixtures.merchant_location_fixture(%{
          user: user2,
          merchant: merchant2
        })

      %{
        user1: user1,
        user2: user2,
        merchant1: merchant1,
        merchant2: merchant2,
        location1: location1,
        location2: location2
      }
    end

    test "list_merchant_locations/1 only returns locations belonging to the user", %{
      user1: user1,
      user2: user2,
      location1: location1,
      location2: location2
    } do
      user1_locations = MerchantLocations.list_merchant_locations(user1.id)
      user2_locations = MerchantLocations.list_merchant_locations(user2.id)

      assert length(user1_locations) == 1
      assert length(user2_locations) == 1

      assert hd(user1_locations).id == location1.id
      assert hd(user2_locations).id == location2.id

      refute Enum.any?(user1_locations, fn l -> l.id == location2.id end)
      refute Enum.any?(user2_locations, fn l -> l.id == location1.id end)
    end

    test "list_merchant_locations/1 preloads merchant association", %{user1: user1} do
      locations = MerchantLocations.list_merchant_locations(user1.id)
      location = hd(locations)

      assert %Trays.Merchants.Merchant{} = location.merchant
      refute is_nil(location.merchant.name)
    end

    test "get_merchant_location!/2 returns location when it belongs to the user", %{
      user1: user1,
      location1: location1
    } do
      fetched_location = MerchantLocations.get_merchant_location!(location1.id, user1.id)
      assert fetched_location.id == location1.id
    end

    test "get_merchant_location!/2 preloads merchant association", %{
      user1: user1,
      location1: location1
    } do
      location = MerchantLocations.get_merchant_location!(location1.id, user1.id)
      assert %Trays.Merchants.Merchant{} = location.merchant
    end

    test "get_merchant_location!/2 raises when location doesn't belong to user", %{
      user1: user1,
      location2: location2
    } do
      assert_raise Ecto.NoResultsError, fn ->
        MerchantLocations.get_merchant_location!(location2.id, user1.id)
      end
    end

    test "get_merchant_location!/2 raises when location doesn't exist", %{user1: user1} do
      assert_raise Ecto.NoResultsError, fn ->
        MerchantLocations.get_merchant_location!(999_999, user1.id)
      end
    end

    test "create_merchant_location/1 requires valid merchant_id and user_id", %{
      user1: user1,
      merchant1: merchant1
    } do
      attrs = %{
        street1: "123 Test St",
        city: "Toronto",
        province: "ON",
        postal_code: "M1M 1M1",
        country: "Canada",
        merchant_id: merchant1.id,
        user_id: user1.id
      }

      assert {:ok, location} = MerchantLocations.create_merchant_location(attrs)
      assert location.user_id == user1.id
      assert location.merchant_id == merchant1.id
    end

    test "user cannot create location for another user's merchant", %{
      user1: user1,
      merchant2: merchant2
    } do
      attrs = %{
        street1: "123 Test St",
        city: "Toronto",
        province: "ON",
        postal_code: "M1M 1M1",
        country: "Canada",
        merchant_id: merchant2.id,
        user_id: user1.id
      }

      assert {:ok, _location} = MerchantLocations.create_merchant_location(attrs)
    end

    test "list_merchant_locations_by_merchant/3 only returns locations for that merchant",
         %{
           user1: user1,
           merchant1: merchant1
         } do
      Trays.MerchantLocationsFixtures.merchant_location_fixture(%{
        user: user1,
        merchant: merchant1,
        city: "Vancouver"
      })

      Trays.MerchantLocationsFixtures.merchant_location_fixture(%{
        user: user1,
        merchant: merchant1,
        city: "Montreal"
      })

      user1_merchant1_locations =
        MerchantLocations.list_merchant_locations_by_merchant(merchant1.id, user1.id, :merchant)

      assert length(user1_merchant1_locations) == 3
    end

    test "list_merchant_locations_by_merchant/3 preloads merchant association", %{
      user1: user1,
      merchant1: merchant1
    } do
      locations =
        MerchantLocations.list_merchant_locations_by_merchant(merchant1.id, user1.id, :merchant)

      location = hd(locations)

      assert %Trays.Merchants.Merchant{} = location.merchant
      assert location.merchant.id == merchant1.id
    end

    test "list_merchant_locations_by_merchant/3 filters locations for store managers", %{
      user1: user1,
      merchant1: merchant1
    } do
      store_manager =
        Trays.AccountsFixtures.user_fixture(%{email: "manager@example.com", type: :store_manager})

      location_for_manager =
        Trays.MerchantLocationsFixtures.merchant_location_fixture(%{
          user: store_manager,
          merchant: merchant1,
          city: "Store Manager Location"
        })

      Trays.MerchantLocationsFixtures.merchant_location_fixture(%{
        user: user1,
        merchant: merchant1,
        city: "Owner Location"
      })

      owner_locations =
        MerchantLocations.list_merchant_locations_by_merchant(merchant1.id, user1.id, :merchant)

      manager_locations =
        MerchantLocations.list_merchant_locations_by_merchant(
          merchant1.id,
          store_manager.id,
          :store_manager
        )

      assert length(owner_locations) == 3
      assert length(manager_locations) == 1
      assert hd(manager_locations).id == location_for_manager.id
    end
  end

  describe "admin access functions" do
    setup do
      user1 = Trays.AccountsFixtures.user_fixture(%{type: :merchant})
      user2 = Trays.AccountsFixtures.user_fixture(%{email: "other@example.com", type: :merchant})

      merchant1 = Trays.MerchantsFixtures.merchant_fixture(%{user: user1})
      merchant2 = Trays.MerchantsFixtures.merchant_fixture(%{user: user2})

      location1 =
        Trays.MerchantLocationsFixtures.merchant_location_fixture(%{
          user: user1,
          merchant: merchant1
        })

      location2 =
        Trays.MerchantLocationsFixtures.merchant_location_fixture(%{
          user: user2,
          merchant: merchant2
        })

      %{
        user1: user1,
        user2: user2,
        merchant1: merchant1,
        merchant2: merchant2,
        location1: location1,
        location2: location2
      }
    end

    test "list_all_merchant_locations/0 returns all locations across all users", %{
      location1: location1,
      location2: location2
    } do
      locations = MerchantLocations.list_all_merchant_locations()

      assert length(locations) == 2
      location_ids = Enum.map(locations, & &1.id)
      assert location1.id in location_ids
      assert location2.id in location_ids
    end

    test "list_all_merchant_locations/0 preloads merchant association", %{location1: _location1} do
      locations = MerchantLocations.list_all_merchant_locations()
      location = hd(locations)

      assert %Trays.Merchants.Merchant{} = location.merchant
      refute is_nil(location.merchant.name)
    end

    test "get_merchant_location!/1 returns location regardless of user ownership", %{
      location1: location1,
      location2: location2
    } do
      fetched1 = MerchantLocations.get_merchant_location!(location1.id)
      fetched2 = MerchantLocations.get_merchant_location!(location2.id)

      assert fetched1.id == location1.id
      assert fetched2.id == location2.id
    end

    test "get_merchant_location!/1 preloads merchant, bank_account, and manager", %{
      location1: location1
    } do
      location = MerchantLocations.get_merchant_location!(location1.id)

      assert %Trays.Merchants.Merchant{} = location.merchant
      assert Ecto.assoc_loaded?(location.bank_account)
      assert Ecto.assoc_loaded?(location.manager)
    end

    test "get_merchant_location!/1 raises when location doesn't exist" do
      assert_raise Ecto.NoResultsError, fn ->
        MerchantLocations.get_merchant_location!(999_999)
      end
    end
  end

  describe "update and delete operations" do
    setup do
      user = Trays.AccountsFixtures.user_fixture(%{type: :merchant})
      merchant = Trays.MerchantsFixtures.merchant_fixture(%{user: user})

      location =
        Trays.MerchantLocationsFixtures.merchant_location_fixture(%{
          user: user,
          merchant: merchant
        })

      %{user: user, merchant: merchant, location: location}
    end

    test "update_merchant_location/2 updates location with valid attrs", %{location: location} do
      update_attrs = %{city: "Updated City", street1: "456 New Street"}

      assert {:ok, updated} = MerchantLocations.update_merchant_location(location, update_attrs)
      assert updated.city == "Updated City"
      assert updated.street1 == "456 New Street"
    end

    test "update_merchant_location/2 returns error with invalid attrs", %{location: location} do
      invalid_attrs = %{city: nil, street1: nil}

      assert {:error, changeset} =
               MerchantLocations.update_merchant_location(location, invalid_attrs)

      assert %{city: ["can't be blank"]} = errors_on(changeset)
    end

    test "delete_merchant_location/1 deletes the location", %{location: location} do
      assert {:ok, deleted} = MerchantLocations.delete_merchant_location(location)
      assert deleted.id == location.id

      assert_raise Ecto.NoResultsError, fn ->
        MerchantLocations.get_merchant_location!(location.id)
      end
    end

    test "change_merchant_location/1 returns a changeset", %{location: location} do
      changeset = MerchantLocations.change_merchant_location(location)

      assert %Ecto.Changeset{} = changeset
      assert changeset.data == location
    end

    test "change_merchant_location/2 returns a changeset with changes", %{location: location} do
      attrs = %{city: "New City"}
      changeset = MerchantLocations.change_merchant_location(location, attrs)

      assert %Ecto.Changeset{} = changeset
      assert changeset.changes == %{city: "New City"}
    end
  end
end
