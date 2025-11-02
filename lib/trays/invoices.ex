defmodule Trays.Invoices do
  @moduledoc """
  The Invoices context.
  """

  import Ecto.Query, warn: false
  alias Trays.Repo

  alias Trays.Invoices.Invoice

  @doc """
  Returns the list of invoices for a specific merchant location.
  """
  def list_invoices(merchant_location_id) do
    Invoice
    |> where([i], i.merchant_location_id == ^merchant_location_id)
    |> order_by([i], desc: i.inserted_at)
    |> Repo.all()
  end

  @doc """
  Gets a single invoice for a specific merchant location.

  Raises `Ecto.NoResultsError` if the Invoice does not exist.
  """
  def get_invoice!(id, merchant_location_id) do
    Invoice
    |> where([i], i.id == ^id and i.merchant_location_id == ^merchant_location_id)
    |> Repo.one!()
  end

  @doc """
  Gets a single invoice with its line items for a specific merchant location.

  Raises `Ecto.NoResultsError` if the Invoice does not exist.
  """
  def get_invoice_with_line_items!(id, merchant_location_id) do
    Invoice
    |> where([i], i.id == ^id and i.merchant_location_id == ^merchant_location_id)
    |> preload(:line_items)
    |> Repo.one!()
  end

  @doc """
  Creates an invoice.
  """
  def create_invoice(attrs \\ %{}) do
    %Invoice{}
    |> Invoice.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates an invoice.
  """
  def update_invoice(%Invoice{} = invoice, attrs) do
    invoice
    |> Invoice.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes an invoice.
  """
  def delete_invoice(%Invoice{} = invoice) do
    Repo.delete(invoice)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking invoice changes.
  """
  def change_invoice(%Invoice{} = invoice, attrs \\ %{}) do
    Invoice.changeset(invoice, attrs)
  end
end
