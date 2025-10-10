defmodule TraysWeb.MerchantLocationLive.Form do
  use TraysWeb, :live_view

  alias Trays.MerchantLocations
  alias Trays.MerchantLocations.MerchantLocation

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage merchant_location records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="merchant_location-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:street1]} type="text" label="Street1" />
        <.input field={@form[:street2]} type="text" label="Street2" />
        <.input field={@form[:city]} type="text" label="City" />
        <.input field={@form[:province]} type="text" label="Province" />
        <.input field={@form[:postal_code]} type="text" label="Postal code" />
        <.input field={@form[:country]} type="text" label="Country" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Merchant location</.button>
          <.button navigate={return_path(@return_to, @merchant_location)}>Cancel</.button>
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
    user_id = socket.assigns.current_scope.user.id
    merchant_location = MerchantLocations.get_merchant_location!(id, user_id)

    socket
    |> assign(:page_title, "Edit Merchant location")
    |> assign(:merchant_location, merchant_location)
    |> assign(:form, to_form(MerchantLocations.change_merchant_location(merchant_location)))
  end

  defp apply_action(socket, :new, _params) do
    merchant_location = %MerchantLocation{}

    socket
    |> assign(:page_title, "New Merchant location")
    |> assign(:merchant_location, merchant_location)
    |> assign(:form, to_form(MerchantLocations.change_merchant_location(merchant_location)))
  end

  @impl true
  def handle_event("validate", %{"merchant_location" => merchant_location_params}, socket) do
    changeset =
      MerchantLocations.change_merchant_location(
        socket.assigns.merchant_location,
        merchant_location_params
      )

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"merchant_location" => merchant_location_params}, socket) do
    save_merchant_location(socket, socket.assigns.live_action, merchant_location_params)
  end

  defp save_merchant_location(socket, :edit, merchant_location_params) do
    case MerchantLocations.update_merchant_location(
           socket.assigns.merchant_location,
           merchant_location_params
         ) do
      {:ok, merchant_location} ->
        {:noreply,
         socket
         |> put_flash(:info, "Merchant location updated successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, merchant_location))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_merchant_location(socket, :new, merchant_location_params) do
    user_id = socket.assigns.current_scope.user.id

    merchant = Trays.Merchants.get_or_create_default_merchant(user_id)

    merchant_location_params =
      merchant_location_params
      |> Map.put("user_id", user_id)
      |> Map.put("merchant_id", merchant.id)

    case MerchantLocations.create_merchant_location(merchant_location_params) do
      {:ok, merchant_location} ->
        {:noreply,
         socket
         |> put_flash(:info, "Merchant location created successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, merchant_location))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path("index", _merchant_location), do: ~p"/merchant_locations"
  defp return_path("show", merchant_location), do: ~p"/merchant_locations/#{merchant_location}"
end
