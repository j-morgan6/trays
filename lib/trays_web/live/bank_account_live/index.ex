defmodule TraysWeb.BankAccountLive.Index do
  use TraysWeb, :live_view

  alias Trays.BankAccounts

  on_mount {TraysWeb.Hooks.Authorize, {:view, :bank_account}}

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {gettext("Listing Bank accounts")}
        <:actions>
          <.button
            variant="primary"
            navigate={~p"/merchant_locations/#{@merchant_location_id}/bank_accounts/new"}
          >
            <.icon name="hero-plus" /> {gettext("New Bank account")}
          </.button>
        </:actions>
      </.header>

      <.table
        id="bank_accounts"
        rows={@streams.bank_accounts}
        row_click={fn {_id, bank_account} -> JS.navigate(~p"/bank_accounts/#{bank_account}") end}
      >
        <:col :let={{_id, bank_account}} label={gettext("Account number")}>
          {bank_account.account_number}
        </:col>
        <:col :let={{_id, bank_account}} label={gettext("Transit number")}>
          {bank_account.transit_number}
        </:col>
        <:col :let={{_id, bank_account}} label={gettext("Institution number")}>
          {bank_account.institution_number}
        </:col>
        <:action :let={{_id, bank_account}}>
          <div class="sr-only">
            <.link navigate={~p"/bank_accounts/#{bank_account}"}>{gettext("Show")}</.link>
          </div>
          <.link navigate={~p"/bank_accounts/#{bank_account}/edit"}>{gettext("Edit")}</.link>
        </:action>
        <:action :let={{id, bank_account}}>
          <.link
            phx-click={JS.push("delete", value: %{id: bank_account.id}) |> hide("##{id}")}
            data-confirm={gettext("Are you sure?")}
          >
            {gettext("Delete")}
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"merchant_location_id" => merchant_location_id}, _session, socket) do
    merchant_location_id = String.to_integer(merchant_location_id)
    bank_accounts = BankAccounts.list_bank_accounts(merchant_location_id)

    {:ok,
     socket
     |> assign(:merchant_location_id, merchant_location_id)
     |> assign(:page_title, gettext("Listing Bank accounts"))
     |> stream(:bank_accounts, bank_accounts)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    bank_account = BankAccounts.get_bank_account!(id)
    {:ok, _} = BankAccounts.delete_bank_account(bank_account)

    {:noreply, stream_delete(socket, :bank_accounts, bank_account)}
  end
end
