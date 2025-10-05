defmodule Trays.Accounts.UserTest do
  use Trays.DataCase

  import Trays.TestHelpers

  alias Trays.Accounts.User
  alias Trays.AccountsFixtures

  setup do
    attrs = AccountsFixtures.valid_user_attributes()
    {:ok, valid_attributes: attrs}
  end

  test "should require some fields", context do
    context.valid_attributes
    |> assert_require_field(:name)
    |> assert_require_field(:phone_number)
  end

  test "should require a valid phone number", context do
    changeset_with(context.valid_attributes, :phone_number, "123456789")
    |> assert_validation_error_on(:phone_number, "must be a 10 digit phone number")

    changeset = changeset_with(context.valid_attributes, :phone_number, "6479922499")
    assert changeset.valid? == true

    changeset = changeset_with(context.valid_attributes, :phone_number, "(647) 992-2499")
    assert changeset.valid? == true

    changeset = changeset_with(context.valid_attributes, :phone_number, "647.992.2499")
    assert changeset.valid? == true
  end

  defp assert_require_field(valid_attrs, field) do
    invalid_attrs = Map.put(valid_attrs, field, "")

    User.registration_changeset(%User{}, invalid_attrs)
    |> assert_validation_error_on(field, "can't be blank")

    valid_attrs
  end

  defp changeset_with(attrs, field, value) do
    attrs = Map.put(attrs, field, value)
    User.registration_changeset(%User{}, attrs)
  end
end
