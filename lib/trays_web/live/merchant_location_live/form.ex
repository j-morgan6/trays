defmodule TraysWeb.MerchantLocationLive.Form do
  use TraysWeb, :live_view

  alias Trays.MerchantLocations
  alias Trays.MerchantLocations.MerchantLocation

  on_mount {TraysWeb.Hooks.Authorize, {:manage, :merchant_location}}

  @impl true
  def mount(params, _session, socket) do
    store_managers = Trays.Accounts.list_store_managers()

    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> assign(:store_managers, store_managers)
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    user_id = socket.assigns.current_scope.user.id
    merchant_location = MerchantLocations.get_merchant_location!(id, user_id)

    socket
    |> assign(:page_title, gettext("Edit Merchant location"))
    |> assign(:merchant_location, merchant_location)
    |> assign(:form, to_form(MerchantLocations.change_merchant_location(merchant_location)))
  end

  defp apply_action(socket, :new, _params) do
    merchant_location = %MerchantLocation{}

    socket
    |> assign(:page_title, gettext("New Merchant location"))
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
    user_id = socket.assigns.current_scope.user.id
    existing_user_id = socket.assigns.merchant_location.user_id

    manager_id = get_manager_id(merchant_location_params["user_id"], existing_user_id || user_id)
    merchant_location_params = Map.put(merchant_location_params, "user_id", manager_id)

    case MerchantLocations.update_merchant_location(
           socket.assigns.merchant_location,
           merchant_location_params
         ) do
      {:ok, merchant_location} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Merchant location updated successfully"))
         |> push_navigate(to: return_path(socket.assigns.return_to, merchant_location))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_merchant_location(socket, :new, merchant_location_params) do
    user_id = socket.assigns.current_scope.user.id
    merchant = Trays.Merchants.get_or_create_default_merchant(user_id)

    manager_id = get_manager_id(merchant_location_params["user_id"], user_id)

    merchant_location_params =
      merchant_location_params
      |> Map.put("user_id", manager_id)
      |> Map.put("merchant_id", merchant.id)

    case MerchantLocations.create_merchant_location(merchant_location_params) do
      {:ok, merchant_location} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Merchant location created successfully"))
         |> push_navigate(to: return_path(socket.assigns.return_to, merchant_location))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp get_manager_id(selected_id, default_id) do
    case selected_id do
      "" -> default_id
      nil -> default_id
      id when is_binary(id) -> String.to_integer(id)
      id -> id
    end
  end

  defp return_path("index", _merchant_location), do: ~p"/merchant_locations"
  defp return_path("show", merchant_location), do: ~p"/merchant_locations/#{merchant_location}"
end
