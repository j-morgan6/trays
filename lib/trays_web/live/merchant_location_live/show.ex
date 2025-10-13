defmodule TraysWeb.MerchantLocationLive.Show do
  use TraysWeb, :live_view

  alias Trays.MerchantLocations

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    user_id = socket.assigns.current_scope.user.id

    {:ok,
     socket
     |> assign(:page_title, gettext("Show Merchant location"))
     |> assign(:merchant_location, MerchantLocations.get_merchant_location!(id, user_id))}
  end
end
