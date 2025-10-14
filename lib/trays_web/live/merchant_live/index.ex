defmodule TraysWeb.MerchantLive.Index do
  use TraysWeb, :live_view

  alias Trays.Merchants

  @impl true
  def mount(_params, _session, socket) do
    merchants_with_counts = Merchants.list_all_merchants_with_location_counts()

    {:ok,
     socket
     |> assign(:page_title, gettext("Merchants"))
     |> assign(:merchant_count, length(merchants_with_counts))
     |> stream_configure(:merchants,
       dom_id: fn %{merchant: merchant} -> "merchant-#{merchant.id}" end
     )
     |> stream(:merchants, merchants_with_counts)}
  end

  @impl true
  def handle_event("delete_merchant", %{"id" => id}, socket) do
    merchant = Trays.Repo.get!(Trays.Merchants.Merchant, id)

    case Merchants.delete_merchant(merchant) do
      {:ok, _merchant} ->
        merchant_with_count = %{merchant: merchant, location_count: 0}

        {:noreply,
         socket
         |> put_flash(:info, gettext("Merchant deleted successfully"))
         |> stream_delete(:merchants, merchant_with_count)
         |> assign(:merchant_count, socket.assigns.merchant_count - 1)}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, gettext("Unable to delete merchant"))}
    end
  end
end
