defmodule Trays.BankAccountsTest do
  use Trays.DataCase

  alias Trays.BankAccounts

  describe "bank_accounts" do
    alias Trays.BankAccounts.BankAccount

    import Trays.BankAccountsFixtures
    import Trays.MerchantLocationsFixtures

    @invalid_attrs %{
      account_number: nil,
      transit_number: nil,
      institution_number: nil,
      merchant_location_id: nil
    }

    test "list_bank_accounts/1 returns all bank_accounts for a merchant_location" do
      merchant_location1 = merchant_location_fixture()
      merchant_location2 = merchant_location_fixture()
      bank_account1 = bank_account_fixture(merchant_location: merchant_location1)
      bank_account2 = bank_account_fixture(merchant_location: merchant_location2)

      assert BankAccounts.list_bank_accounts(merchant_location1.id) == [bank_account1]
      assert BankAccounts.list_bank_accounts(merchant_location2.id) == [bank_account2]
    end

    test "get_bank_account!/1 returns the bank_account with given id" do
      bank_account = bank_account_fixture()
      assert BankAccounts.get_bank_account!(bank_account.id) == bank_account
    end

    test "get_bank_account!/1 raises when bank_account does not exist" do
      assert_raise Ecto.NoResultsError, fn -> BankAccounts.get_bank_account!(0) end
    end

    test "create_bank_account/1 with valid data creates a bank_account" do
      merchant_location = merchant_location_fixture()

      valid_attrs = %{
        account_number: "some account_number",
        transit_number: "some transit_number",
        institution_number: "some institution_number",
        merchant_location_id: merchant_location.id
      }

      assert {:ok, %BankAccount{} = bank_account} =
               BankAccounts.create_bank_account(valid_attrs)

      assert bank_account.account_number == "some account_number"
      assert bank_account.transit_number == "some transit_number"
      assert bank_account.institution_number == "some institution_number"
      assert bank_account.merchant_location_id == merchant_location.id
    end

    test "create_bank_account/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = BankAccounts.create_bank_account(@invalid_attrs)
    end

    test "update_bank_account/2 with valid data updates the bank_account" do
      bank_account = bank_account_fixture()

      update_attrs = %{
        account_number: "some updated account_number",
        transit_number: "some updated transit_number",
        institution_number: "some updated institution_number"
      }

      assert {:ok, %BankAccount{} = bank_account} =
               BankAccounts.update_bank_account(bank_account, update_attrs)

      assert bank_account.account_number == "some updated account_number"
      assert bank_account.transit_number == "some updated transit_number"
      assert bank_account.institution_number == "some updated institution_number"
    end

    test "update_bank_account/2 with invalid data returns error changeset" do
      bank_account = bank_account_fixture()

      assert {:error, %Ecto.Changeset{}} =
               BankAccounts.update_bank_account(bank_account, @invalid_attrs)

      assert bank_account == BankAccounts.get_bank_account!(bank_account.id)
    end

    test "delete_bank_account/1 deletes the bank_account" do
      bank_account = bank_account_fixture()
      assert {:ok, %BankAccount{}} = BankAccounts.delete_bank_account(bank_account)

      assert_raise Ecto.NoResultsError, fn ->
        BankAccounts.get_bank_account!(bank_account.id)
      end
    end

    test "change_bank_account/1 returns a bank_account changeset" do
      bank_account = bank_account_fixture()
      assert %Ecto.Changeset{} = BankAccounts.change_bank_account(bank_account)
    end
  end
end
