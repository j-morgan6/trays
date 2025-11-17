defmodule TraysWeb.MerchantLocationLive.Show do
  use TraysWeb, :live_view

  alias Trays.BankAccounts
  alias Trays.Invoices
  alias Trays.MerchantLocations

  on_mount {TraysWeb.Hooks.Authorize, {:view, :merchant_location}}

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    location = MerchantLocations.get_merchant_location!(id, socket.assigns.current_scope.user.id)
    invoices = Invoices.list_invoices(location.id)

    {:ok,
     socket
     |> assign(:page_title, gettext("Location Details"))
     |> assign(:location, location)
     |> assign(:invoice_count, length(invoices))
     |> stream(:invoices, invoices)}
  end

  @impl true
  def handle_event("delete_bank_account", %{"id" => id}, socket) do
    bank_account = BankAccounts.get_bank_account!(id)
    {:ok, _} = BankAccounts.delete_bank_account(bank_account)

    location =
      MerchantLocations.get_merchant_location!(
        socket.assigns.location.id,
        socket.assigns.current_scope.user.id
      )

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

    # TODO: Send the email
    {:noreply,
     socket
     |> put_flash(:info, "Preparing to send invoice #{invoice.number} to #{invoice.email}")}
  end
end
