defmodule TraysWeb.Plugs.Authorize do
  @moduledoc """
  Plug for controller-level authorization based on user roles and permissions.

  ## Usage

      plug TraysWeb.Plugs.Authorize, action: :manage, resource: :menu
      plug TraysWeb.Plugs.Authorize, action: :view, resource: :orders

  """
  import Plug.Conn
  import Phoenix.Controller
  alias Trays.Accounts

  def init(opts), do: opts

  def call(conn, opts) do
    action = Keyword.get(opts, :action)
    resource = Keyword.get(opts, :resource)
    user = conn.assigns[:current_user]

    if user && Accounts.can?(user, action, resource) do
      conn
    else
      conn
      |> put_flash(:error, "You are not authorized to perform this action.")
      |> redirect(to: "/")
      |> halt()
    end
  end
end
