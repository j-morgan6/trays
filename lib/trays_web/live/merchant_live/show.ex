defmodule TraysWeb.MerchantLive.Show do
  use TraysWeb, :live_view

  alias Trays.MerchantLocations
  alias Trays.Merchants

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div class="mb-6">
          <.link
            navigate={~p"/merchants"}
            class="inline-flex items-center gap-2 text-sm text-base-content/70 hover:text-[#85b4cf] transition-colors"
          >
            <.icon name="hero-arrow-left" class="size-4" /> Back to Merchants
          </.link>
        </div>

        <div class="space-y-6">
          <div class="bg-white rounded-xl shadow-sm border border-base-content/10 overflow-hidden">
            <div class="bg-gradient-to-br from-[#85b4cf] to-[#6a94ab] px-6 py-8">
              <div class="flex items-start justify-between">
                <div class="flex items-start gap-4">
                  <div class="w-16 h-16 bg-white/20 backdrop-blur-sm rounded-xl flex items-center justify-center flex-shrink-0">
                    <.icon name="hero-building-storefront" class="size-10 text-white" />
                  </div>
                  <div class="text-white">
                    <h1 class="text-3xl font-bold">{@merchant.name}</h1>
                    <p class="mt-2 text-white/90 text-lg">{@merchant.description}</p>
                  </div>
                </div>
                <div class="flex items-center gap-2">
                  <.link
                    navigate={~p"/merchants/#{@merchant}/edit?return_to=show"}
                    class="inline-flex items-center gap-2 px-4 py-2 text-sm font-medium text-white hover:bg-white/20 border border-white/50 rounded-lg transition-all duration-200"
                  >
                    <.icon name="hero-pencil-square" class="size-4" /> Edit
                  </.link>
                  <.link
                    phx-click="delete"
                    data-confirm="Are you sure? This will delete the merchant and all its locations."
                    class="inline-flex items-center gap-2 px-4 py-2 text-sm font-medium text-white hover:bg-red-600 border border-white/50 rounded-lg transition-all duration-200"
                  >
                    <.icon name="hero-trash" class="size-4" /> Delete
                  </.link>
                </div>
              </div>
            </div>

            <div class="p-6 bg-base-content/5">
              <div class="flex items-center gap-6">
                <div class="flex items-center gap-3">
                  <div class="w-12 h-12 bg-[#85b4cf]/10 rounded-lg flex items-center justify-center">
                    <.icon name="hero-map-pin" class="size-6 text-[#85b4cf]" />
                  </div>
                  <div>
                    <p class="text-sm text-base-content/70">Total Locations</p>
                    <p class="text-2xl font-bold text-base-content">{@location_count}</p>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <div class="bg-white rounded-xl shadow-sm border border-base-content/10 overflow-hidden">
            <div class="px-6 py-4 border-b border-base-content/10 flex items-center justify-between">
              <h2 class="text-lg font-semibold text-base-content">
                Locations
                <span class="ml-2 text-base-content/60 font-normal">({@location_count})</span>
              </h2>
              <.link
                navigate={~p"/merchant_locations/new?merchant_id=#{@merchant.id}"}
                class="inline-flex items-center gap-2 px-4 py-2 text-sm font-medium text-white bg-gradient-to-br from-[#85b4cf] to-[#6a94ab] rounded-lg hover:shadow-lg transition-all duration-200"
              >
                <.icon name="hero-plus" class="size-4" /> Add Location
              </.link>
            </div>

            <%= if @location_count == 0 do %>
              <div class="px-6 py-12 text-center">
                <.icon name="hero-map-pin" class="mx-auto size-12 text-base-content/30" />
                <h3 class="mt-4 text-lg font-semibold text-base-content">No locations yet</h3>
                <p class="mt-2 text-sm text-base-content/70">
                  Add your first location to start managing this business
                </p>
                <div class="mt-6">
                  <.link
                    navigate={~p"/merchant_locations/new?merchant_id=#{@merchant.id}"}
                    class="inline-flex items-center gap-2 px-4 py-2 text-sm font-medium text-white bg-gradient-to-br from-[#85b4cf] to-[#6a94ab] rounded-lg hover:shadow-lg transition-all duration-200"
                  >
                    <.icon name="hero-plus" class="size-4" /> Add First Location
                  </.link>
                </div>
              </div>
            <% else %>
              <div class="overflow-x-auto">
                <table class="w-full">
                  <thead>
                    <tr class="border-b border-base-content/10 bg-base-content">
                      <th class="px-6 py-4 text-left text-xs font-semibold text-white uppercase tracking-wider">
                        Address
                      </th>
                      <th class="px-6 py-4 text-left text-xs font-semibold text-white uppercase tracking-wider">
                        City
                      </th>
                      <th class="px-6 py-4 text-left text-xs font-semibold text-white uppercase tracking-wider">
                        Province
                      </th>
                      <th class="px-6 py-4 text-right text-xs font-semibold text-white uppercase tracking-wider">
                        Actions
                      </th>
                    </tr>
                  </thead>
                  <tbody
                    id="locations"
                    phx-update="stream"
                    class="divide-y divide-base-content/5"
                  >
                    <tr
                      :for={{id, location} <- @streams.locations}
                      id={id}
                      class="group hover:bg-[#85b4cf]/5 transition-colors cursor-pointer"
                      phx-click={JS.navigate(~p"/merchant_locations/#{location}")}
                    >
                      <td class="px-6 py-4">
                        <div class="flex items-center gap-3">
                          <div class="flex-shrink-0 w-10 h-10 bg-gradient-to-br from-[#e88e19] to-[#d17d15] rounded-lg flex items-center justify-center">
                            <.icon name="hero-map-pin" class="size-5 text-white" />
                          </div>
                          <div>
                            <div class="font-medium text-base-content">{location.street1}</div>
                            <div :if={location.street2} class="text-sm text-base-content/70">
                              {location.street2}
                            </div>
                          </div>
                        </div>
                      </td>
                      <td class="px-6 py-4">
                        <div class="text-sm text-base-content">{location.city}</div>
                      </td>
                      <td class="px-6 py-4">
                        <div class="text-sm text-base-content">
                          {location.province} {location.postal_code}
                        </div>
                      </td>
                      <td class="px-6 py-4 text-right">
                        <div
                          class="flex items-center justify-end gap-2"
                          phx-click="stop_propagation"
                        >
                          <.link
                            navigate={~p"/merchant_locations/#{location}/edit"}
                            class="inline-flex items-center gap-1 px-3 py-1.5 text-xs font-medium text-[#85b4cf] hover:text-white hover:bg-[#85b4cf] border border-[#85b4cf] rounded-lg transition-all duration-200"
                          >
                            <.icon name="hero-pencil-square" class="size-3.5" /> Edit
                          </.link>
                          <.link
                            phx-click={JS.push("delete_location", value: %{id: location.id})}
                            data-confirm="Are you sure you want to delete this location?"
                            class="inline-flex items-center gap-1 px-3 py-1.5 text-xs font-medium text-red-600 hover:text-white hover:bg-red-600 border border-red-600 rounded-lg transition-all duration-200"
                          >
                            <.icon name="hero-trash" class="size-3.5" /> Delete
                          </.link>
                        </div>
                      </td>
                    </tr>
                  </tbody>
                </table>
              </div>
            <% end %>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    user_id = socket.assigns.current_scope.user.id
    merchant = Merchants.get_merchant!(id, user_id)
    locations = MerchantLocations.list_merchant_locations_by_merchant(merchant.id, user_id)

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
  def handle_event("delete", _params, socket) do
    case Merchants.delete_merchant(socket.assigns.merchant) do
      {:ok, _merchant} ->
        {:noreply,
         socket
         |> put_flash(:info, "Merchant deleted successfully")
         |> push_navigate(to: ~p"/merchants")}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Unable to delete merchant")}
    end
  end

  def handle_event("delete_location", %{"id" => id}, socket) do
    user_id = socket.assigns.current_scope.user.id
    location = MerchantLocations.get_merchant_location!(id, user_id)

    case MerchantLocations.delete_merchant_location(location) do
      {:ok, _location} ->
        {:noreply,
         socket
         |> put_flash(:info, "Location deleted successfully")
         |> stream_delete(:locations, location)
         |> assign(:location_count, socket.assigns.location_count - 1)}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Unable to delete location")}
    end
  end
end
