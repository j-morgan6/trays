defmodule TraysWeb.InvoiceLive.Form do
  use TraysWeb, :live_view

  alias Trays.Invoices
  alias Trays.MerchantLocations

  on_mount {TraysWeb.Hooks.Authorize, {:manage, :invoice}}

  @impl true
  def mount(params, _session, socket) do
    merchant_location_id = params["merchant_location_id"]

    merchant_location =
      MerchantLocations.get_merchant_location!(
        merchant_location_id,
        socket.assigns.current_scope.user.id
      )

    {:ok,
     socket
     |> assign(:merchant_location, merchant_location)
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, gettext("New Invoice"))
    |> assign(:invoice, %Invoices.Invoice{line_items: []})
    |> assign(:line_items, [])
    |> assign(:form, to_form(Invoices.change_invoice(%Invoices.Invoice{})))
    |> assign(:line_item_form, to_form(Invoices.change_line_item(%Invoices.LineItem{})))
    |> assign(:subtotal, Money.new(0))
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    invoice = Invoices.get_invoice_with_line_items!(id, socket.assigns.merchant_location.id)

    socket
    |> assign(:page_title, gettext("Edit Invoice"))
    |> assign(:invoice, invoice)
    |> assign(:line_items, invoice.line_items)
    |> assign(:form, to_form(Invoices.change_invoice(invoice)))
    |> assign(:line_item_form, to_form(Invoices.change_line_item(%Invoices.LineItem{})))
    |> assign(:subtotal, calculate_subtotal(invoice.line_items))
  end

  @impl true
  def handle_event("validate", %{"invoice" => invoice_params}, socket) do
    changeset =
      socket.assigns.invoice
      |> Invoices.change_invoice(invoice_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, form: to_form(changeset))}
  end

  @impl true
  def handle_event("validate_field", _params, socket) do
    form_params = extract_form_params(socket.assigns.form)

    changeset =
      socket.assigns.invoice
      |> Invoices.change_invoice(form_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, form: to_form(changeset))}
  end

  @impl true
  def handle_event("save", %{"invoice" => invoice_params}, socket) do
    save_invoice(socket, socket.assigns.live_action, invoice_params)
  end

  @impl true
  def handle_event("validate_line_item", %{"line_item" => line_item_params}, socket) do
    changeset =
      %Invoices.LineItem{}
      |> Invoices.change_line_item(line_item_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, line_item_form: to_form(changeset))}
  end

  @impl true
  def handle_event("add_line_item", %{"line_item" => line_item_params}, socket) do
    invoice = socket.assigns.invoice

    if invoice.id do
      line_item_params = Map.put(line_item_params, "invoice_id", invoice.id)

      case Invoices.create_line_item(line_item_params) do
        {:ok, _line_item} ->
          updated_invoice = Invoices.get_invoice_with_line_items!(invoice.id, socket.assigns.merchant_location.id)

          {:noreply,
           socket
           |> assign(:line_items, updated_invoice.line_items)
           |> assign(:subtotal, calculate_subtotal(updated_invoice.line_items))
           |> assign(:line_item_form, to_form(Invoices.change_line_item(%Invoices.LineItem{})))
           |> put_flash(:info, gettext("Line item added successfully"))}

        {:error, %Ecto.Changeset{} = changeset} ->
          {:noreply, assign(socket, line_item_form: to_form(changeset))}
      end
    else
      {:noreply,
       socket
       |> put_flash(:error, gettext("Please save the invoice first before adding line items"))}
    end
  end

  @impl true
  def handle_event("delete_line_item", %{"id" => id}, socket) do
    line_item = Enum.find(socket.assigns.line_items, &(&1.id == String.to_integer(id)))

    case Invoices.delete_line_item(line_item) do
      {:ok, _line_item} ->
        updated_invoice = Invoices.get_invoice_with_line_items!(socket.assigns.invoice.id, socket.assigns.merchant_location.id)

        {:noreply,
         socket
         |> assign(:line_items, updated_invoice.line_items)
         |> assign(:subtotal, calculate_subtotal(updated_invoice.line_items))
         |> put_flash(:info, gettext("Line item deleted successfully"))}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, gettext("Could not delete line item"))}
    end
  end

  defp save_invoice(socket, :new, invoice_params) do
    invoice_params =
      Map.put(invoice_params, "merchant_location_id", socket.assigns.merchant_location.id)

    case Invoices.create_invoice(invoice_params) do
      {:ok, _invoice} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Invoice created successfully"))
         |> push_navigate(to: ~p"/merchant_locations/#{socket.assigns.merchant_location}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_invoice(socket, :edit, invoice_params) do
    case Invoices.update_invoice(socket.assigns.invoice, invoice_params) do
      {:ok, _invoice} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Invoice updated successfully"))
         |> push_navigate(to: ~p"/merchant_locations/#{socket.assigns.merchant_location}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp extract_form_params(form) do
    form.params || %{}
  end

  defp calculate_subtotal(line_items) do
    Enum.reduce(line_items, Money.new(0), fn line_item, acc ->
      line_total = Money.multiply(line_item.amount, line_item.quantity)
      Money.add(acc, line_total)
    end)
  end
end
