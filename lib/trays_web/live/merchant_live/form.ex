defmodule TraysWeb.MerchantLive.Form do
  use TraysWeb, :live_view

  alias Trays.Merchants
  alias Trays.Merchants.Merchant

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div class="mb-6">
          <.link
            navigate={~p"/merchants"}
            class="inline-flex items-center gap-2 text-sm text-base-content/70 hover:text-[#85b4cf] transition-colors"
          >
            <.icon name="hero-arrow-left" class="size-4" /> Back to Dashboard
          </.link>
        </div>

        <div class="bg-white rounded-xl shadow-sm border border-base-content/10 overflow-hidden">
          <div class="bg-gradient-to-br from-[#85b4cf] to-[#6a94ab] px-6 py-6">
            <div class="flex items-center gap-3">
              <div class="w-12 h-12 bg-white/20 backdrop-blur-sm rounded-lg flex items-center justify-center">
                <.icon name="hero-pencil-square" class="size-6 text-white" />
              </div>
              <div class="text-white">
                <h1 class="text-2xl font-bold">{@page_title}</h1>
                <p class="text-white/90 text-sm mt-1">
                  Update your business information
                </p>
              </div>
            </div>
          </div>

          <div class="p-6">
            <.form
              for={@form}
              id="merchant-form"
              phx-change="validate"
              phx-submit="save"
              class="space-y-6"
            >
              <div class="space-y-6">
                <div>
                  <div class="flex items-center justify-between mb-2">
                    <label class="block text-sm font-semibold text-base-content">
                      Business Name <span class="text-red-500 ml-1">*</span>
                    </label>
                    <span class={[
                      "text-xs font-medium transition-colors",
                      get_char_count_class(@name_length, 100)
                    ]}>
                      {@name_length}/100
                    </span>
                  </div>
                  <input
                    type="text"
                    name="merchant[name]"
                    id="merchant_name"
                    value={@form[:name].value}
                    placeholder="e.g., Pizza Palace, Joe's Coffee Shop, Sunset Bakery"
                    phx-debounce="300"
                    maxlength="100"
                    class={[
                      "block w-full rounded-lg border transition-all duration-200",
                      "px-4 py-3 text-base-content placeholder:text-base-content/40",
                      "focus:outline-none focus:ring-2 focus:ring-offset-1",
                      get_input_classes(@form[:name])
                    ]}
                  />
                  <%= if @form[:name].errors != [] do %>
                    <div class="mt-2 flex items-start gap-2 text-sm text-red-600">
                      <.icon name="hero-exclamation-circle" class="size-4 mt-0.5 flex-shrink-0" />
                      <span>{translate_error(List.first(@form[:name].errors))}</span>
                    </div>
                  <% else %>
                    <p class="mt-2 text-sm text-base-content/60 flex items-start gap-2">
                      <.icon name="hero-information-circle" class="size-4 mt-0.5 flex-shrink-0" />
                      <span>This is your main business name displayed throughout the dashboard.</span>
                    </p>
                  <% end %>
                </div>

                <div>
                  <div class="flex items-center justify-between mb-2">
                    <label class="block text-sm font-semibold text-base-content">
                      Business Description <span class="text-red-500 ml-1">*</span>
                    </label>
                    <span class={[
                      "text-xs font-medium transition-colors",
                      get_char_count_class(@description_length, 500)
                    ]}>
                      {@description_length}/500
                    </span>
                  </div>
                  <textarea
                    name="merchant[description]"
                    id="merchant_description"
                    rows="4"
                    phx-debounce="300"
                    maxlength="500"
                    placeholder="Describe your business in a few sentences. Include what makes it unique, the type of products or services you offer, and any other key details..."
                    class={[
                      "block w-full rounded-lg border transition-all duration-200",
                      "px-4 py-3 text-base-content placeholder:text-base-content/40",
                      "focus:outline-none focus:ring-2 focus:ring-offset-1",
                      "resize-none",
                      get_input_classes(@form[:description])
                    ]}
                  ><%= @form[:description].value %></textarea>
                  <%= if @form[:description].errors != [] do %>
                    <div class="mt-2 flex items-start gap-2 text-sm text-red-600">
                      <.icon name="hero-exclamation-circle" class="size-4 mt-0.5 flex-shrink-0" />
                      <span>{translate_error(List.first(@form[:description].errors))}</span>
                    </div>
                  <% end %>
                </div>
              </div>

              <div class="flex items-center justify-between gap-3 pt-6 border-t border-base-content/10">
                <.link
                  navigate={~p"/merchants"}
                  class="inline-flex items-center gap-2 px-6 py-2.5 text-sm font-medium text-base-content/70 hover:text-base-content hover:bg-base-content/5 border border-base-content/20 rounded-lg transition-all duration-200"
                >
                  <.icon name="hero-arrow-left" class="size-4" /> Cancel
                </.link>
                <button
                  type="submit"
                  disabled={!@form.source.valid?}
                  phx-disable-with="Saving..."
                  class={[
                    "inline-flex items-center gap-2 px-8 py-3 text-sm font-semibold rounded-lg transition-all duration-200",
                    "focus:outline-none focus:ring-2 focus:ring-[#e88e19] focus:ring-offset-2",
                    if(@form.source.valid?,
                      do:
                        "text-white bg-gradient-to-br from-[#e88e19] to-[#d17d15] hover:shadow-lg hover:scale-105 cursor-pointer",
                      else: "text-base-content/40 bg-base-content/10 cursor-not-allowed"
                    )
                  ]}
                >
                  <.icon name="hero-check-circle" class="size-5" /> Save Changes
                </button>
              </div>
            </.form>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end

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
    |> assign(:page_title, "Edit Business")
    |> assign(:merchant, merchant)
    |> assign(:name_length, String.length(merchant.name || ""))
    |> assign(:description_length, String.length(merchant.description || ""))
    |> assign(:form, to_form(Merchants.change_merchant(merchant)))
  end

  defp apply_action(socket, :new, _params) do
    merchant = %Merchant{}

    socket
    |> assign(:page_title, "New Business")
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
         |> put_flash(:info, "Business updated successfully")
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
         |> put_flash(:info, "Business created successfully")
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
