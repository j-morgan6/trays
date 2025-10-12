defmodule TraysWeb.MerchantLive.Index do
  use TraysWeb, :live_view

  alias Trays.MerchantLocations
  alias Trays.Merchants

  @impl true
  def mount(_params, _session, socket) do
    user_id = socket.assigns.current_scope.user.id
    merchant = get_or_create_merchant(user_id)
    locations = MerchantLocations.list_merchant_locations_by_merchant(merchant.id)

    {:ok,
     socket
     |> assign(:page_title, merchant.name)
     |> assign(:merchant, merchant)
     |> assign(:location_count, length(locations))
     |> stream_configure(:locations,
       dom_id: fn location -> "location-#{location.id}" end
     )
     |> stream(:locations, locations)}
  end

  @impl true
  def handle_event("delete_location", %{"id" => id}, socket) do
    user_id = socket.assigns.current_scope.user.id
    location = MerchantLocations.get_merchant_location!(id, user_id)

    case MerchantLocations.delete_merchant_location(location) do
      {:ok, _location} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Location deleted successfully"))
         |> stream_delete(:locations, location)
         |> assign(:location_count, socket.assigns.location_count - 1)}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, gettext("Unable to delete location"))}
    end
  end

  defp get_or_create_merchant(user_id) do
    case Merchants.list_merchants(user_id) do
      [] ->
        {:ok, merchant} =
          Merchants.create_merchant(%{
            user_id: user_id,
            name: gettext("My Business"),
            description: gettext("Manage your business and locations")
          })
        merchant

      [merchant | _] ->
        merchant
    end
  end
end
