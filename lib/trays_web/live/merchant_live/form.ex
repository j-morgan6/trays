defmodule TraysWeb.MerchantLive.Form do
  use TraysWeb, :live_view

  alias Trays.Merchants
  alias Trays.Merchants.Merchant

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> assign(:name_length, 0)
     |> assign(:description_length, 0)
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    user_id = socket.assigns.current_scope.user.id
    merchant = Merchants.get_merchant!(id, user_id)

    socket
    |> assign(:page_title, gettext("Edit Business"))
    |> assign(:merchant, merchant)
    |> assign(:name_length, String.length(merchant.name || ""))
    |> assign(:description_length, String.length(merchant.description || ""))
    |> assign(:form, to_form(Merchants.change_merchant(merchant)))
  end

  defp apply_action(socket, :new, _params) do
    merchant = %Merchant{}

    socket
    |> assign(:page_title, gettext("New Business"))
    |> assign(:merchant, merchant)
    |> assign(:name_length, 0)
    |> assign(:description_length, 0)
    |> assign(:form, to_form(Merchants.change_merchant(merchant)))
  end

  @impl true
  def handle_event("validate", %{"merchant" => merchant_params}, socket) do
    changeset =
      socket.assigns.merchant
      |> Merchants.change_merchant(merchant_params)
      |> Map.put(:action, :validate)

    name_length = String.length(merchant_params["name"] || "")
    description_length = String.length(merchant_params["description"] || "")

    {:noreply,
     socket
     |> assign(:form, to_form(changeset))
     |> assign(:name_length, name_length)
     |> assign(:description_length, description_length)}
  end

  def handle_event("save", %{"merchant" => merchant_params}, socket) do
    save_merchant(socket, socket.assigns.live_action, merchant_params)
  end

  defp save_merchant(socket, :edit, merchant_params) do
    case Merchants.update_merchant(socket.assigns.merchant, merchant_params) do
      {:ok, _merchant} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Business updated successfully"))
         |> push_navigate(to: ~p"/merchants")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_merchant(socket, :new, merchant_params) do
    merchant_params = Map.put(merchant_params, "user_id", socket.assigns.current_scope.user.id)

    case Merchants.create_merchant(merchant_params) do
      {:ok, _merchant} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Business created successfully"))
         |> push_navigate(to: ~p"/merchants")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp get_char_count_class(length, max) do
    cond do
      length == 0 -> "text-base-content/40"
      length >= max -> "text-red-600 font-semibold"
      length >= max * 0.9 -> "text-amber-600 font-semibold"
      length >= max * 0.75 -> "text-amber-500"
      true -> "text-base-content/60"
    end
  end

  defp get_input_classes(field) do
    cond do
      field.errors != [] ->
        "border-red-300 bg-red-50 focus:border-red-500 focus:ring-red-500"

      field.value && field.value != "" ->
        "border-emerald-300 bg-emerald-50/30 focus:border-emerald-500 focus:ring-emerald-500"

      true ->
        "border-base-content/20 bg-white focus:border-[#85b4cf] focus:ring-[#85b4cf]"
    end
  end
end
