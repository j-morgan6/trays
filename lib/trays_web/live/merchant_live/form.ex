defmodule TraysWeb.MerchantLive.Form do
  use TraysWeb, :live_view

  alias Trays.Merchants
  alias Trays.Merchants.Merchant

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage merchant records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="merchant-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:description]} type="text" label="Description" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Merchant</.button>
          <.button navigate={return_path(@return_to, @merchant)}>Cancel</.button>
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
    merchant = Merchants.get_merchant!(id)

    socket
    |> assign(:page_title, "Edit Merchant")
    |> assign(:merchant, merchant)
    |> assign(:form, to_form(Merchants.change_merchant(merchant)))
  end

  defp apply_action(socket, :new, _params) do
    merchant = %Merchant{}

    socket
    |> assign(:page_title, "New Merchant")
    |> assign(:merchant, merchant)
    |> assign(:form, to_form(Merchants.change_merchant(merchant)))
  end

  @impl true
  def handle_event("validate", %{"merchant" => merchant_params}, socket) do
    changeset = Merchants.change_merchant(socket.assigns.merchant, merchant_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"merchant" => merchant_params}, socket) do
    save_merchant(socket, socket.assigns.live_action, merchant_params)
  end

  defp save_merchant(socket, :edit, merchant_params) do
    case Merchants.update_merchant(socket.assigns.merchant, merchant_params) do
      {:ok, merchant} ->
        {:noreply,
         socket
         |> put_flash(:info, "Merchant updated successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, merchant))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_merchant(socket, :new, merchant_params) do
    merchant_params = Map.put(merchant_params, "user_id", socket.assigns.current_scope.user.id)

    case Merchants.create_merchant(merchant_params) do
      {:ok, merchant} ->
        {:noreply,
         socket
         |> put_flash(:info, "Merchant created successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, merchant))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path("index", _merchant), do: ~p"/merchants"
  defp return_path("show", merchant), do: ~p"/merchants/#{merchant}"
end
