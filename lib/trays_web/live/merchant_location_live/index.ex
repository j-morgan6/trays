defmodule TraysWeb.MerchantLocationLive.Index do
  use TraysWeb, :live_view

  alias Trays.MerchantLocations

  on_mount {TraysWeb.Hooks.Authorize, {:list, :merchant_locations}}

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.current_scope.user

    locations = list_locations_for_user(user)
    location_count = length(locations)

    {:ok,
     socket
     |> assign(:location_count, location_count)
     |> stream(:locations, locations)}
  end

  defp list_locations_for_user(%{type: :admin}), do: MerchantLocations.list_all_merchant_locations()
  defp list_locations_for_user(user), do: MerchantLocations.list_merchant_locations(user.id)
end
