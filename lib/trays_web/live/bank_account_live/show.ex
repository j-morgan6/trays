defmodule TraysWeb.BankAccountLive.Show do
  use TraysWeb, :live_view

  alias Trays.BankAccounts

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {gettext("Bank account")} {@bank_account.id}
        <:subtitle>{gettext("This is a bank_account record from your database.")}</:subtitle>
        <:actions>
          <.button navigate={~p"/merchant_locations/#{@merchant_location_id}/bank_accounts"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button
            variant="primary"
            navigate={~p"/bank_accounts/#{@bank_account}/edit?return_to=show"}
          >
            <.icon name="hero-pencil-square" /> {gettext("Edit bank_account")}
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title={gettext("Account number")}>{@bank_account.account_number}</:item>
        <:item title={gettext("Transit number")}>{@bank_account.transit_number}</:item>
        <:item title={gettext("Institution number")}>{@bank_account.institution_number}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    bank_account = BankAccounts.get_bank_account!(id)

    {:ok,
     socket
     |> assign(:page_title, gettext("Show Bank account"))
     |> assign(:bank_account, bank_account)
     |> assign(:merchant_location_id, bank_account.merchant_location_id)}
  end
end
