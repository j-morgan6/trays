defmodule Trays.Emails.Renderer do
  @moduledoc """
  Renders email templates using EEx.
  Handles both the layout and template rendering.
  """

  require EEx

  @templates_dir "lib/trays/emails/templates"
  @layouts_dir "lib/trays/emails/layouts"

  # Compile templates at build time for performance
  EEx.function_from_file(:defp, :render_layout, Path.join(@layouts_dir, "email.html.heex"), [
    :_assigns
  ])

  EEx.function_from_file(
    :defp,
    :render_invoice_template,
    Path.join(@templates_dir, "invoice.html.heex"),
    [:assigns]
  )

  @doc """
  Renders the invoice email with layout.
  Returns the complete HTML string.
  """
  def render_invoice(assigns) do
    inner_content = render_invoice_template(assigns)
    render_layout(Map.put(assigns, :inner_content, inner_content))
  end
end
