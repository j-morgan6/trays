defmodule Trays.InvoicesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Trays.Invoices` context.
  """

  alias Trays.Invoices

  @doc """
  Generate an invoice.
  """
  def invoice_fixture(attrs \\ %{}) do
    merchant_location =
      attrs[:merchant_location] ||
        Trays.MerchantLocationsFixtures.merchant_location_fixture()

    attrs =
      attrs
      |> Map.delete(:merchant_location)
      |> Enum.into(%{
        name: "John Doe",
        email: "john@example.com",
        address: "123 Main St, Toronto, ON M5V 1A1",
        phone_number: "555-1234",
        number: "INV-#{System.unique_integer([:positive])}",
        gst_hst: Decimal.new("13.00"),
        total_amount: Decimal.new("113.00"),
        terms: :net30,
        delivery_date: ~D[2025-01-01],
        status: :outstanding,
        merchant_location_id: merchant_location.id
      })

    {:ok, invoice} = Invoices.create_invoice(attrs)
    invoice
  end
end
