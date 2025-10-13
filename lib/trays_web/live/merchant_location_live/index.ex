defmodule TraysWeb.MerchantLocationLive.Index do
  use TraysWeb, :live_view

  alias Trays.MerchantLocations

  @impl true
  def mount(_params, _session, socket) do
    user_id = socket.assigns.current_scope.user.id

    {:ok,
     socket
     |> assign(:page_title, gettext("Listing Merchant locations"))
     |> stream(:merchant_locations, list_merchant_locations(user_id))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    user_id = socket.assigns.current_scope.user.id
    merchant_location = MerchantLocations.get_merchant_location!(id, user_id)
    {:ok, _} = MerchantLocations.delete_merchant_location(merchant_location)

    {:noreply, stream_delete(socket, :merchant_locations, merchant_location)}
  end

  defp list_merchant_locations(user_id) do
    MerchantLocations.list_merchant_locations(user_id)
  end
end
