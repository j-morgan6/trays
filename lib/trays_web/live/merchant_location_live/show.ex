defmodule TraysWeb.MerchantLocationLive.Show do
  use TraysWeb, :live_view

  alias Trays.MerchantLocations

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Merchant location {@merchant_location.id}
        <:subtitle>This is a merchant_location record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/merchant_locations"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button
            variant="primary"
            navigate={~p"/merchant_locations/#{@merchant_location}/edit?return_to=show"}
          >
            <.icon name="hero-pencil-square" /> Edit merchant_location
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Street1">{@merchant_location.street1}</:item>
        <:item title="Street2">{@merchant_location.street2}</:item>
        <:item title="City">{@merchant_location.city}</:item>
        <:item title="Province">{@merchant_location.province}</:item>
        <:item title="Postal code">{@merchant_location.postal_code}</:item>
        <:item title="Country">{@merchant_location.country}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show Merchant location")
     |> assign(:merchant_location, MerchantLocations.get_merchant_location!(id))}
  end
end
