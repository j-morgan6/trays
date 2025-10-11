defmodule TraysWeb.MerchantLocationLive.Show do
  use TraysWeb, :live_view

  alias Trays.MerchantLocations

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {gettext("Merchant location")} {@merchant_location.id}
        <:subtitle>
          {gettext("This is a merchant_location record from your database.")}
        </:subtitle>
        <:actions>
          <.button navigate={~p"/merchant_locations"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button
            variant="primary"
            navigate={~p"/merchant_locations/#{@merchant_location}/edit?return_to=show"}
          >
            <.icon name="hero-pencil-square" /> {gettext("Edit merchant_location")}
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title={gettext("Street1")}>{@merchant_location.street1}</:item>
        <:item title={gettext("Street2")}>{@merchant_location.street2}</:item>
        <:item title={gettext("City")}>{@merchant_location.city}</:item>
        <:item title={gettext("Province")}>{@merchant_location.province}</:item>
        <:item title={gettext("Postal code")}>{@merchant_location.postal_code}</:item>
        <:item title={gettext("Country")}>{@merchant_location.country}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    user_id = socket.assigns.current_scope.user.id

    {:ok,
     socket
     |> assign(:page_title, gettext("Show Merchant location"))
     |> assign(:merchant_location, MerchantLocations.get_merchant_location!(id, user_id))}
  end
end
