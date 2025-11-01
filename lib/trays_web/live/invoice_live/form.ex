defmodule TraysWeb.InvoiceLive.Form do
  use TraysWeb, :live_view

  alias Trays.Invoices
  alias Trays.MerchantLocations

  on_mount {TraysWeb.Hooks.Authorize, {:manage, :invoice}}

  @impl true
  def mount(params, _session, socket) do
    merchant_location_id = params["merchant_location_id"]

    merchant_location =
      MerchantLocations.get_merchant_location!(
        merchant_location_id,
        socket.assigns.current_scope.user.id
      )

    {:ok,
     socket
     |> assign(:merchant_location, merchant_location)
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, gettext("New Invoice"))
    |> assign(:invoice, %Invoices.Invoice{})
    |> assign(:form, to_form(Invoices.change_invoice(%Invoices.Invoice{})))
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    invoice = Invoices.get_invoice!(id, socket.assigns.merchant_location.id)

    socket
    |> assign(:page_title, gettext("Edit Invoice"))
    |> assign(:invoice, invoice)
    |> assign(:form, to_form(Invoices.change_invoice(invoice)))
  end

  @impl true
  def handle_event("validate", %{"invoice" => invoice_params}, socket) do
    changeset =
      socket.assigns.invoice
      |> Invoices.change_invoice(invoice_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, form: to_form(changeset))}
  end

  @impl true
  def handle_event("validate_field", _params, socket) do
    form_params = extract_form_params(socket.assigns.form)

    changeset =
      socket.assigns.invoice
      |> Invoices.change_invoice(form_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, form: to_form(changeset))}
  end

  defp extract_form_params(form) do
    form.params || %{}
  end

  @impl true
  def handle_event("save", %{"invoice" => invoice_params}, socket) do
    save_invoice(socket, socket.assigns.live_action, invoice_params)
  end

  defp save_invoice(socket, :new, invoice_params) do
    invoice_params =
      Map.put(invoice_params, "merchant_location_id", socket.assigns.merchant_location.id)

    case Invoices.create_invoice(invoice_params) do
      {:ok, _invoice} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Invoice created successfully"))
         |> push_navigate(to: ~p"/merchant_locations/#{socket.assigns.merchant_location}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_invoice(socket, :edit, invoice_params) do
    case Invoices.update_invoice(socket.assigns.invoice, invoice_params) do
      {:ok, _invoice} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Invoice updated successfully"))
         |> push_navigate(to: ~p"/merchant_locations/#{socket.assigns.merchant_location}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
end
