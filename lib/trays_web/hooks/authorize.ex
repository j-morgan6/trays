defmodule TraysWeb.Hooks.Authorize do
  @moduledoc """
  LiveView hook for authorization based on user roles and permissions.

  ## Usage

      defmodule TraysWeb.MenuLive.Index do
        use TraysWeb, :live_view

        on_mount {TraysWeb.Hooks.Authorize, {:manage, :menu}}
        # ...
      end

  """
  import Phoenix.LiveView
  alias Trays.Accounts

  def on_mount({action, resource}, _params, _session, socket) do
    user = get_current_user(socket)

    if user && Accounts.can?(user, action, resource) do
      {:cont, socket}
    else
      {:halt,
       socket
       |> put_flash(:error, "You are not authorized to access this page.")
       |> redirect(to: "/")}
    end
  end

  defp get_current_user(socket) do
    case socket.assigns do
      %{current_scope: %{user: user}} -> user
      %{current_user: user} -> user
      _ -> nil
    end
  end
end
