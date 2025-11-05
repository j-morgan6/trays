defmodule Trays.Invoices do
  @moduledoc """
  The Invoices context.
  """

  import Ecto.Query, warn: false

  alias Trays.Invoices.Invoice
  alias Trays.Invoices.LineItem
  alias Trays.Repo

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
  Creates an invoice with associated line items in a single transaction.
  """
  def create_invoice_with_line_items(invoice_attrs, line_items_attrs) do
    Repo.transaction(fn ->
      case create_invoice(invoice_attrs) do
        {:ok, invoice} ->
          Enum.each(line_items_attrs, fn line_item_attrs ->
            line_item_attrs_with_invoice = Map.put(line_item_attrs, :invoice_id, invoice.id)

            case create_line_item(line_item_attrs_with_invoice) do
              {:ok, _line_item} -> :ok
              {:error, changeset} -> Repo.rollback(changeset)
            end
          end)

          invoice

        {:error, changeset} ->
          Repo.rollback(changeset)
      end
    end)
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

  @doc """
  Creates a line item for an invoice.
  """
  def create_line_item(attrs \\ %{}) do
    %LineItem{}
    |> LineItem.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Deletes a line item.
  """
  def delete_line_item(%LineItem{} = line_item) do
    Repo.delete(line_item)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking line item changes.
  """
  def change_line_item(%LineItem{} = line_item, attrs \\ %{}) do
    LineItem.changeset(line_item, attrs)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking temporary line item changes.
  """
  def change_temp_line_item(%LineItem{} = line_item, attrs \\ %{}) do
    LineItem.temp_changeset(line_item, attrs)
  end
end
