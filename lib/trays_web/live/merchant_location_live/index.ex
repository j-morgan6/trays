defmodule TraysWeb.MerchantLocationLive.Index do
  use TraysWeb, :live_view

  alias Trays.MerchantLocations

  on_mount {TraysWeb.Hooks.Authorize, {:list, :merchant_locations}}

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.current_scope.user

    locations = MerchantLocations.list_merchant_locations(user.id)
    location_count = length(locations)

    {:ok,
     socket
     |> assign(:location_count, location_count)
     |> stream(:locations, locations)}
  end

  @impl true
  def handle_event("delete_location", %{"id" => id}, socket) do
    user = socket.assigns.current_scope.user
    location = MerchantLocations.get_merchant_location!(id, user.id)

    case MerchantLocations.delete_merchant_location(location) do
      {:ok, _location} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Location deleted successfully"))
         |> stream_delete(:locations, location)
         |> update(:location_count, &(&1 - 1))}

      {:error, _changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, gettext("Unable to delete location"))}
    end
  end
end
