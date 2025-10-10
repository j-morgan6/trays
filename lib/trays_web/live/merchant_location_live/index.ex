defmodule TraysWeb.MerchantLocationLive.Index do
  use TraysWeb, :live_view

  alias Trays.MerchantLocations

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Listing Merchant locations
        <:actions>
          <.button variant="primary" navigate={~p"/merchant_locations/new"}>
            <.icon name="hero-plus" /> New Merchant location
          </.button>
        </:actions>
      </.header>

      <.table
        id="merchant_locations"
        rows={@streams.merchant_locations}
        row_click={
          fn {_id, merchant_location} -> JS.navigate(~p"/merchant_locations/#{merchant_location}") end
        }
      >
        <:col :let={{_id, merchant_location}} label="Street1">{merchant_location.street1}</:col>
        <:col :let={{_id, merchant_location}} label="Street2">{merchant_location.street2}</:col>
        <:col :let={{_id, merchant_location}} label="City">{merchant_location.city}</:col>
        <:col :let={{_id, merchant_location}} label="Province">{merchant_location.province}</:col>
        <:col :let={{_id, merchant_location}} label="Postal code">
          {merchant_location.postal_code}
        </:col>
        <:col :let={{_id, merchant_location}} label="Country">{merchant_location.country}</:col>
        <:action :let={{_id, merchant_location}}>
          <div class="sr-only">
            <.link navigate={~p"/merchant_locations/#{merchant_location}"}>Show</.link>
          </div>
          <.link navigate={~p"/merchant_locations/#{merchant_location}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, merchant_location}}>
          <.link
            phx-click={JS.push("delete", value: %{id: merchant_location.id}) |> hide("##{id}")}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    user_id = socket.assigns.current_scope.user.id

    {:ok,
     socket
     |> assign(:page_title, "Listing Merchant locations")
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
