defmodule TraysWeb.BankAccountLive.Form do
  use TraysWeb, :live_view

  alias Trays.BankAccounts
  alias Trays.BankAccounts.BankAccount

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
          <.button navigate={return_path(@merchant_location_id, @return_to, @bank_account)}>
            {gettext("Cancel")}
          </.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    bank_account = BankAccounts.get_bank_account!(id)

    socket
    |> assign(:page_title, gettext("Edit Bank account"))
    |> assign(:bank_account, bank_account)
    |> assign(:merchant_location_id, bank_account.merchant_location_id)
    |> assign(:form, to_form(BankAccounts.change_bank_account(bank_account)))
  end

  defp apply_action(socket, :new, %{"merchant_location_id" => merchant_location_id}) do
    bank_account = %BankAccount{merchant_location_id: String.to_integer(merchant_location_id)}

    socket
    |> assign(:page_title, gettext("New Bank account"))
    |> assign(:bank_account, bank_account)
    |> assign(:merchant_location_id, String.to_integer(merchant_location_id))
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
      {:ok, bank_account} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Bank account updated successfully"))
         |> push_navigate(
           to:
             return_path(
               socket.assigns.merchant_location_id,
               socket.assigns.return_to,
               bank_account
             )
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_bank_account(socket, :new, bank_account_params) do
    case BankAccounts.create_bank_account(bank_account_params) do
      {:ok, bank_account} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Bank account created successfully"))
         |> push_navigate(
           to:
             return_path(
               socket.assigns.merchant_location_id,
               socket.assigns.return_to,
               bank_account
             )
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path(merchant_location_id, "index", _bank_account) do
    ~p"/merchant_locations/#{merchant_location_id}/bank_accounts"
  end

  defp return_path(_merchant_location_id, "show", bank_account) do
    ~p"/bank_accounts/#{bank_account}"
  end
end
