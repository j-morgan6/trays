defmodule TraysWeb.MerchantLive.Index do
  use TraysWeb, :live_view

  alias Trays.Merchants

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div class="flex items-center justify-between gap-6 pb-4">
          <%= if @merchant_count > 0 do %>
            <div class="flex items-center gap-3 flex-1">
              <div class="bg-gradient-to-br from-[#85b4cf] to-[#6a94ab] rounded-lg shadow-md px-6 py-4 flex-1">
                <div class="flex items-center gap-3">
                  <.icon name="hero-building-storefront" class="size-6 text-white" />
                  <div class="text-white">
                    <p class="text-sm font-medium opacity-90">Total Merchants</p>
                    <p class="text-3xl font-bold">{@merchant_count}</p>
                  </div>
                </div>
              </div>
              <div class="bg-gradient-to-br from-[#e88e19] to-[#d17d15] rounded-lg shadow-md px-6 py-4 flex-1">
                <div class="flex items-center gap-3">
                  <.icon name="hero-map-pin" class="size-6 text-white" />
                  <div class="text-white">
                    <p class="text-sm font-medium opacity-90">Total Locations</p>
                    <p class="text-3xl font-bold">{@location_count}</p>
                  </div>
                </div>
              </div>
            </div>
          <% end %>
          <.button variant="primary" navigate={~p"/merchants/new"} class="gap-2 flex-shrink-0">
            <.icon name="hero-plus" class="size-5" /> New Merchant
          </.button>
        </div>

        <%= if @merchant_count == 0 do %>
          <div class="mt-12 text-center">
            <.icon name="hero-building-storefront" class="mx-auto size-16 text-base-content/30" />
            <h3 class="mt-4 text-xl font-semibold text-base-content">No merchants yet</h3>
            <p class="mt-2 text-base-content/70">
              Create your first merchant to start managing your business
            </p>
            <div class="mt-6">
              <.button variant="primary" navigate={~p"/merchants/new"} class="gap-2">
                <.icon name="hero-plus" class="size-5" /> Create Merchant
              </.button>
            </div>
          </div>
        <% else %>
          <div class="mt-8">
            <div class="bg-white rounded-xl shadow-sm border border-base-content/10 overflow-hidden">
              <div class="overflow-x-auto">
                <table class="w-full">
                  <thead>
                    <tr class="border-b border-base-content/10 bg-base-content">
                      <th class="px-6 py-4 text-left text-xs font-semibold text-white uppercase tracking-wider">
                        Merchant
                      </th>
                      <th class="px-6 py-4 text-left text-xs font-semibold text-white uppercase tracking-wider">
                        Description
                      </th>
                      <th class="px-6 py-4 text-left text-xs font-semibold text-white uppercase tracking-wider">
                        Locations
                      </th>
                      <th class="px-6 py-4 text-right text-xs font-semibold text-white uppercase tracking-wider">
                        Actions
                      </th>
                    </tr>
                  </thead>
                  <tbody id="merchants" phx-update="stream" class="divide-y divide-base-content/5">
                    <tr
                      :for={{id, merchant} <- @streams.merchants}
                      id={id}
                      class="group hover:bg-[#85b4cf]/5 transition-colors cursor-pointer"
                      phx-click={JS.navigate(~p"/merchants/#{merchant.merchant}")}
                    >
                      <td class="px-6 py-4">
                        <div class="flex items-center gap-3">
                          <div class="flex-shrink-0 w-10 h-10 bg-gradient-to-br from-[#85b4cf] to-[#6a94ab] rounded-lg flex items-center justify-center">
                            <.icon name="hero-building-storefront" class="size-5 text-white" />
                          </div>
                          <div>
                            <div class="font-semibold text-base-content group-hover:text-[#85b4cf] transition-colors">
                              {merchant.merchant.name}
                            </div>
                          </div>
                        </div>
                      </td>
                      <td class="px-6 py-4">
                        <div class="text-sm text-base-content/70 max-w-md line-clamp-2">
                          {merchant.merchant.description}
                        </div>
                      </td>
                      <td class="px-6 py-4">
                        <span class="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full text-xs font-semibold bg-[#85b4cf]/10 text-[#85b4cf] border border-[#85b4cf]/20">
                          <.icon name="hero-map-pin" class="size-3.5" />
                          {merchant.location_count}
                          <span class="font-normal">
                            {if merchant.location_count == 1, do: "location", else: "locations"}
                          </span>
                        </span>
                      </td>
                      <td class="px-6 py-4 text-right">
                        <div class="flex items-center justify-end gap-2" phx-click="stop_propagation">
                          <.link
                            navigate={~p"/merchants/#{merchant.merchant}/edit"}
                            class="inline-flex items-center gap-1 px-3 py-1.5 text-xs font-medium text-[#85b4cf] hover:text-white hover:bg-[#85b4cf] border border-[#85b4cf] rounded-lg transition-all duration-200"
                          >
                            <.icon name="hero-pencil-square" class="size-3.5" /> Edit
                          </.link>
                          <.link
                            phx-click={JS.push("delete", value: %{id: merchant.merchant.id})}
                            data-confirm="Are you sure? This will also delete all associated locations."
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
            </div>
          </div>
        <% end %>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    user_id = socket.assigns.current_scope.user.id
    merchants_with_counts = list_merchants_with_counts(user_id)
    total_locations = get_total_locations(user_id)

    {:ok,
     socket
     |> assign(:page_title, "Your Merchants")
     |> assign(:merchant_count, length(merchants_with_counts))
     |> assign(:location_count, total_locations)
     |> stream_configure(:merchants,
       dom_id: fn %{merchant: merchant} -> "merchant-#{merchant.id}" end
     )
     |> stream(:merchants, merchants_with_counts)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    user_id = socket.assigns.current_scope.user.id
    merchant = Merchants.get_merchant!(id, user_id)
    {:ok, _} = Merchants.delete_merchant(merchant)

    {:noreply, stream_delete(socket, :merchants, %{merchant: merchant, location_count: 0})}
  end

  defp list_merchants_with_counts(user_id) do
    Merchants.list_merchants_with_location_counts(user_id)
  end

  defp get_total_locations(user_id) do
    Trays.MerchantLocations.list_merchant_locations(user_id)
    |> length()
  end
end
