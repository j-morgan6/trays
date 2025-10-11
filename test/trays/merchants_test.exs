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

    test "get_merchants_for_select/1 returns sorted by name" do
      user1 = Trays.AccountsFixtures.user_fixture(%{email: "user1@test.com", type: :merchant})
      user2 = Trays.AccountsFixtures.user_fixture(%{email: "user2@test.com", type: :merchant})
      user3 = Trays.AccountsFixtures.user_fixture(%{email: "user3@test.com", type: :merchant})

      merchant1 =
        Trays.MerchantsFixtures.merchant_fixture(%{
          user: user1,
          name: "Zebra Merchant",
          description: "Last alphabetically"
        })

      merchant2 =
        Trays.MerchantsFixtures.merchant_fixture(%{
          user: user2,
          name: "Apple Merchant",
          description: "First alphabetically"
        })

      merchant3 =
        Trays.MerchantsFixtures.merchant_fixture(%{
          user: user3,
          name: "Middle Merchant",
          description: "Middle alphabetically"
        })

      all_merchants = [merchant1, merchant2, merchant3]
      names = Enum.map(all_merchants, fn m -> m.name end) |> Enum.sort()

      assert names == ["Apple Merchant", "Middle Merchant", "Zebra Merchant"]
    end
  end
end
