defmodule Trays.Emails do
  @moduledoc """
  Functions for building and sending emails.
  """

  import Swoosh.Email

  alias Trays.Emails.Renderer

  # Example email - can be removed later
  def foo_email do
    new()
    |> to("foo@example.com")
    |> from("bar@example.com")
    |> subject("Hello")
    |> text_body("This is a simple email")
  end

  @doc """
  Sends an invoice email to a client with payment details.

  ## Parameters
    - client_email: Email address of the client
    - client_name: Name of the client
    - invoice_number: Invoice number (e.g., "INV-001")
    - due_date: Due date string (e.g., "January 31, 2025")
    - line_items: List of line items, each with :description, :details (optional), and :amount
    - total: Total amount (formatted string, e.g., "$1,234.56")
    - payment_url: Stripe payment link URL
    - opts: Optional fields
      - :subtotal - Subtotal amount (formatted string)
      - :tax - Tax amount (formatted string)
      - :message - Custom message to client (defaults to standard message)
      - :payment_terms - Payment terms text
      - :from_email - Sender email (defaults to "invoices@trays.com")
      - :from_name - Sender name (defaults to "Trays")

  ## Example
      Emails.invoice_email(
        "client@example.com",
        "John Smith",
        "INV-001",
        "January 31, 2025",
        [
          %{description: "Web Development", details: "Homepage redesign", amount: "$2,500.00"},
          %{description: "Hosting (Annual)", details: nil, amount: "$120.00"}
        ],
        "$2,620.00",
        "https://stripe.com/pay/inv_xxx",
        message: "Thank you for your continued partnership!",
        payment_terms: "Payment due within 30 days."
      )
  """
  def invoice_email(
        client_email,
        client_name,
        invoice_number,
        due_date,
        line_items,
        total,
        payment_url,
        opts \\ []
      ) do

        # TODO: Update from_email and from_name to use the correct email and name
    from_email = Keyword.get(opts, :from_email, "onboarding@resend.dev")
    from_name = Keyword.get(opts, :from_name, "Trays")

    message =
      Keyword.get(
        opts,
        :message,
        "Here's your invoice for the services provided. Please review the details below."
      )

    # Build template assigns
    assigns = %{
      client_name: client_name,
      invoice_number: invoice_number,
      due_date: due_date,
      message: message,
      line_items: line_items,
      subtotal: Keyword.get(opts, :subtotal),
      tax: Keyword.get(opts, :tax),
      total: total,
      payment_url: payment_url,
      payment_terms: Keyword.get(opts, :payment_terms)
    }

    # Render HTML
    html_body = Renderer.render_invoice(assigns)

    # Generate plain text version (simplified)
    text_body = generate_invoice_text(assigns)

    new()
    |> to(client_email)
    |> from({from_name, from_email})
    |> subject("Invoice #{invoice_number} from #{from_name}")
    |> html_body(html_body)
    |> text_body(text_body)
  end

  # Generate a plain text version of the invoice for email clients that don't support HTML
  defp generate_invoice_text(assigns) do
    """
    Invoice ##{assigns.invoice_number}
    Due #{assigns.due_date}

    Hi #{assigns.client_name},

    #{assigns.message}

    INVOICE DETAILS
    ---------------
    #{Enum.map_join(assigns.line_items, "\n", fn item ->
      description = if Map.get(item, :details), do: "#{item.description} - #{Map.get(item, :details)}", else: item.description
      "#{description}: #{item.amount}"
    end)}

    #{if assigns.subtotal, do: "Subtotal: #{assigns.subtotal}\n", else: ""}#{if assigns.tax, do: "Tax: #{assigns.tax}\n", else: ""}Total: #{assigns.total}

    PAY YOUR INVOICE
    ----------------
    Click here to pay securely with Stripe:
    #{assigns.payment_url}

    #{if assigns.payment_terms, do: "\nPayment Terms:\n#{assigns.payment_terms}\n", else: ""}
    Thank you for your business!
    The Trays Team
    """
  end
end
