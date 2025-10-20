defmodule TraysWeb.InvoiceLive.Show do
  use TraysWeb, :live_view

  alias Trays.Invoices
  alias Trays.MerchantLocations

  @impl true
  def mount(%{"merchant_location_id" => location_id, "id" => id}, _session, socket) do
    merchant_location =
      MerchantLocations.get_merchant_location!(
        location_id,
        socket.assigns.current_scope.user.id
      )

    invoice = Invoices.get_invoice!(id, location_id)

    {:ok,
     socket
     |> assign(:page_title, "Invoice ##{invoice.number}")
     |> assign(:merchant_location, merchant_location)
     |> assign(:invoice, invoice)}
  end

  @impl true
  def handle_event("delete", _params, socket) do
    {:ok, _} = Invoices.delete_invoice(socket.assigns.invoice)

    {:noreply,
     socket
     |> put_flash(:info, gettext("Invoice deleted successfully"))
     |> push_navigate(to: ~p"/merchant_locations/#{socket.assigns.merchant_location}")}
  end
end
