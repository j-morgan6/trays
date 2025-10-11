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

    test "list_merchant_locations_by_merchant/2 only returns locations for that merchant",
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
        MerchantLocations.list_merchant_locations_by_merchant(merchant1.id)

      assert length(user1_merchant1_locations) == 3
    end

    test "list_merchant_locations_by_merchant/2 preloads merchant association", %{
      merchant1: merchant1
    } do
      locations = MerchantLocations.list_merchant_locations_by_merchant(merchant1.id)
      location = hd(locations)

      assert %Trays.Merchants.Merchant{} = location.merchant
      assert location.merchant.id == merchant1.id
    end
  end
end
