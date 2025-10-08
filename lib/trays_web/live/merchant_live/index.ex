defmodule TraysWeb.MerchantLive.Index do
  use TraysWeb, :live_view

  alias Trays.Merchants

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Listing Merchants
        <:actions>
          <.button variant="primary" navigate={~p"/merchants/new"}>
            <.icon name="hero-plus" /> New Merchant
          </.button>
        </:actions>
      </.header>

      <.table
        id="merchants"
        rows={@streams.merchants}
        row_click={fn {_id, merchant} -> JS.navigate(~p"/merchants/#{merchant}") end}
      >
        <:col :let={{_id, merchant}} label="Name">{merchant.name}</:col>
        <:col :let={{_id, merchant}} label="Description">{merchant.description}</:col>
        <:action :let={{_id, merchant}}>
          <div class="sr-only">
            <.link navigate={~p"/merchants/#{merchant}"}>Show</.link>
          </div>
          <.link navigate={~p"/merchants/#{merchant}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, merchant}}>
          <.link
            phx-click={JS.push("delete", value: %{id: merchant.id}) |> hide("##{id}")}
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
    {:ok,
     socket
     |> assign(:page_title, "Listing Merchants")
     |> stream(:merchants, list_merchants())}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    merchant = Merchants.get_merchant!(id)
    {:ok, _} = Merchants.delete_merchant(merchant)

    {:noreply, stream_delete(socket, :merchants, merchant)}
  end

  defp list_merchants do
    Merchants.list_merchants()
  end
end
