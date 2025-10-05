defmodule Trays.TestHelpers do
  use ExUnit.Case

  def assert_validation_error_on(changeset, field, msg) do
    assert changeset.valid? == false
    assert Keyword.keys(changeset.errors) == [field]
    assert %{field => [msg]} == Trays.DataCase.errors_on(changeset)
  end

  def string_of_length(len) do
    Enum.reduce(1..len, "", fn _, acc -> "x" <> acc end)
  end

  def changeset_with(changeset_fn, attrs, field, value) do
    attrs = Map.put(attrs, field, value)
    changeset_fn.(attrs)
  end

  def assert_require_field(valid_attrs, changeset_fn, field) do
    invalid_attrs = Map.put(valid_attrs, field, "")

    changeset_fn.(invalid_attrs)
    |> assert_validation_error_on(field, "can't be blank")

    valid_attrs
  end
end
