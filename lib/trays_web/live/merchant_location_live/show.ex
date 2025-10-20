defmodule TraysWeb.MerchantLocationLive.Show do
  use TraysWeb, :live_view

  alias Trays.BankAccounts
  alias Trays.Invoices
  alias Trays.MerchantLocations
  alias Trays.Repo

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    location =
      MerchantLocations.get_merchant_location!(id, socket.assigns.current_scope.user.id)
      |> Repo.preload([:merchant, :bank_account, :manager])

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
      |> Repo.preload([:merchant, :bank_account, :manager])

    {:noreply,
     socket
     |> put_flash(:info, gettext("Bank account deleted successfully"))
     |> assign(:location, location)}
  end
end
