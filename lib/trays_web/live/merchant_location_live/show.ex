defmodule TraysWeb.MerchantLocationLive.Show do
  use TraysWeb, :live_view

  alias Trays.BankAccounts
  alias Trays.Emails
  alias Trays.Invoices
  alias Trays.Mailer
  alias Trays.MerchantLocations

  on_mount {TraysWeb.Hooks.Authorize, {:view, :merchant_location}}

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    user = socket.assigns.current_scope.user
    location = get_location_for_user(id, user)
    invoices = Invoices.list_invoices(location.id)

    {:ok,
     socket
     |> assign(:page_title, gettext("Location Details"))
     |> assign(:location, location)
     |> assign(:invoice_count, length(invoices))
     |> stream(:invoices, invoices)}
  end

  defp get_location_for_user(id, %{type: :admin}),
    do: MerchantLocations.get_merchant_location!(id)

  defp get_location_for_user(id, user), do: MerchantLocations.get_merchant_location!(id, user.id)

  @impl true
  def handle_event("delete_bank_account", %{"id" => id}, socket) do
    bank_account = BankAccounts.get_bank_account!(id)
    {:ok, _} = BankAccounts.delete_bank_account(bank_account)

    user = socket.assigns.current_scope.user
    location = get_location_for_user(socket.assigns.location.id, user)

    {:noreply,
     socket
     |> put_flash(:info, gettext("Bank account deleted successfully"))
     |> assign(:location, location)}
  end

  @impl true
  def handle_event("send_invoice_email", %{"invoice_id" => invoice_id}, socket) do
    invoice =
      Invoices.get_invoice_with_line_items!(
        invoice_id,
        socket.assigns.location.id
      )

    # Format line items for email template
    line_items =
      Enum.map(invoice.line_items, fn item ->
        %{
          description: item.description,
          details: "Quantity: #{item.quantity}",
          amount: Money.to_string(item.amount)
        }
      end)

    # Calculate due date (using delivery date or 30 days from now)
    due_date = format_date(invoice.delivery_date)

    # Format amounts
    subtotal_amount = Money.subtract(invoice.total_amount, invoice.gst_hst)
    subtotal = Money.to_string(subtotal_amount)
    tax = Money.to_string(invoice.gst_hst)
    total = Money.to_string(invoice.total_amount)

    # TODO: Replace with actual payment URL (Stripe link)
    payment_url = "https://example.com/pay/#{invoice.id}"

    # Build and send email
    email =
      Emails.invoice_email(
        invoice.email,
        invoice.name,
        invoice.number,
        due_date,
        line_items,
        total,
        payment_url,
        subtotal: subtotal,
        tax: tax,
        from_name: socket.assigns.location.merchant.name
      )

    case Mailer.deliver(email) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Invoice #{invoice.number} sent to #{invoice.email}")}

      {:error, _reason} ->
        {:noreply,
         socket
         |> put_flash(:error, "Failed to send invoice email. Please try again.")}
    end
  end

  defp format_date(date) do
    Calendar.strftime(date, "%B %d, %Y")
  end
end
