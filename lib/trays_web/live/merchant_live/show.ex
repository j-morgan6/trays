defmodule TraysWeb.MerchantLive.Show do
  use TraysWeb, :live_view

  alias Trays.MerchantLocations
  alias Trays.Merchants

  on_mount {TraysWeb.Hooks.Authorize, {:view, :merchant}}

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    user = socket.assigns.current_scope.user
    merchant = get_merchant_for_user(id, user)

    locations =
      MerchantLocations.list_merchant_locations_by_merchant(merchant.id, user.id, user.type)

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

  defp get_merchant_for_user(id, %{type: :admin}), do: Merchants.get_merchant!(id)
  defp get_merchant_for_user(id, user), do: Merchants.get_merchant!(id, user.id)

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
end
