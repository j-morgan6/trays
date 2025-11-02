defmodule Trays.LineItemsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Trays.Invoices.LineItem` schema.
  """

  alias Trays.Invoices.LineItem
  alias Trays.Repo

  @doc """
  Generate a line item.
  """
  def line_item_fixture(attrs \\ %{}) do
    invoice =
      attrs[:invoice] ||
        Trays.InvoicesFixtures.invoice_fixture()

    attrs =
      attrs
      |> Map.delete(:invoice)
      |> Enum.into(%{
        description: "Test Product #{System.unique_integer([:positive])}",
        quantity: 1,
        amount: Money.new(10_000),
        invoice_id: invoice.id
      })

    {:ok, line_item} =
      %LineItem{}
      |> LineItem.changeset(attrs)
      |> Repo.insert()

    line_item
  end
end
