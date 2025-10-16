defmodule TraysWeb.BankAccountLive.Form do
  use TraysWeb, :live_view

  alias Trays.BankAccounts
  alias Trays.BankAccounts.BankAccount

  on_mount {TraysWeb.Hooks.Authorize, {:manage, :bank_account}}

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
        <:subtitle>
          {gettext("Use this form to manage bank_account records in your database.")}
        </:subtitle>
      </.header>

      <.form for={@form} id="bank_account-form" phx-change="validate" phx-submit="save">
        <input
          type="hidden"
          name="bank_account[merchant_location_id]"
          value={@merchant_location_id}
        />
        <.input field={@form[:account_number]} type="text" label={gettext("Account number")} />
        <.input field={@form[:transit_number]} type="text" label={gettext("Transit number")} />
        <.input
          field={@form[:institution_number]}
          type="text"
          label={gettext("Institution number")}
        />
        <footer>
          <.button phx-disable-with={gettext("Saving...")} variant="primary">
            {gettext("Save Bank account")}
          </.button>
          <.button navigate={~p"/merchants/#{@merchant}"}>
            {gettext("Cancel")}
          </.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    bank_account = BankAccounts.get_bank_account!(id)

    merchant_location =
      Trays.Repo.get!(Trays.MerchantLocations.MerchantLocation, bank_account.merchant_location_id)

    merchant_location = Trays.Repo.preload(merchant_location, :merchant)

    socket
    |> assign(:page_title, gettext("Edit Bank account"))
    |> assign(:bank_account, bank_account)
    |> assign(:merchant_location_id, bank_account.merchant_location_id)
    |> assign(:merchant, merchant_location.merchant)
    |> assign(:form, to_form(BankAccounts.change_bank_account(bank_account)))
  end

  defp apply_action(socket, :new, %{"merchant_location_id" => merchant_location_id}) do
    bank_account = %BankAccount{merchant_location_id: String.to_integer(merchant_location_id)}

    merchant_location =
      Trays.Repo.get!(
        Trays.MerchantLocations.MerchantLocation,
        String.to_integer(merchant_location_id)
      )

    merchant_location = Trays.Repo.preload(merchant_location, :merchant)

    socket
    |> assign(:page_title, gettext("New Bank account"))
    |> assign(:bank_account, bank_account)
    |> assign(:merchant_location_id, String.to_integer(merchant_location_id))
    |> assign(:merchant, merchant_location.merchant)
    |> assign(:form, to_form(BankAccounts.change_bank_account(bank_account)))
  end

  @impl true
  def handle_event("validate", %{"bank_account" => bank_account_params}, socket) do
    changeset =
      BankAccounts.change_bank_account(socket.assigns.bank_account, bank_account_params)

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"bank_account" => bank_account_params}, socket) do
    save_bank_account(socket, socket.assigns.live_action, bank_account_params)
  end

  defp save_bank_account(socket, :edit, bank_account_params) do
    case BankAccounts.update_bank_account(socket.assigns.bank_account, bank_account_params) do
      {:ok, _bank_account} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Bank account updated successfully"))
         |> push_navigate(to: ~p"/merchants/#{socket.assigns.merchant}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_bank_account(socket, :new, bank_account_params) do
    case BankAccounts.create_bank_account(bank_account_params) do
      {:ok, _bank_account} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Bank account created successfully"))
         |> push_navigate(to: ~p"/merchants/#{socket.assigns.merchant}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
end
