defmodule TraysWeb.MerchantLive.Show do
  use TraysWeb, :live_view

  alias Trays.Merchants

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Merchant {@merchant.id}
        <:subtitle>This is a merchant record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/merchants"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/merchants/#{@merchant}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit merchant
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Name">{@merchant.name}</:item>
        <:item title="Description">{@merchant.description}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show Merchant")
     |> assign(:merchant, Merchants.get_merchant!(id))}
  end
end
