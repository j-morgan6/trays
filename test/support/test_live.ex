defmodule TraysWeb.TestLive do
  @moduledoc false
  use Phoenix.LiveView

  on_mount {TraysWeb.Hooks.Authorize, {:manage, :menu}}

  def render(assigns) do
    ~H"""
    <div>Authorized Content</div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end

defmodule TraysWeb.TestViewOrdersLive do
  @moduledoc false
  use Phoenix.LiveView

  on_mount {TraysWeb.Hooks.Authorize, {:view, :orders}}

  def render(assigns) do
    ~H"""
    <div>View Orders Content</div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end

defmodule TraysWeb.TestCreateOrderLive do
  @moduledoc false
  use Phoenix.LiveView

  on_mount {TraysWeb.Hooks.Authorize, {:create, :order}}

  def render(assigns) do
    ~H"""
    <div>Create Order Content</div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end

defmodule TraysWeb.TestViewMenuLive do
  @moduledoc false
  use Phoenix.LiveView

  on_mount {TraysWeb.Hooks.Authorize, {:view, :menu}}

  def render(assigns) do
    ~H"""
    <div>View Menu Content</div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end

defmodule TraysWeb.TestManageOrdersLive do
  @moduledoc false
  use Phoenix.LiveView

  on_mount {TraysWeb.Hooks.Authorize, {:manage, :orders}}

  def render(assigns) do
    ~H"""
    <div>Manage Orders Content</div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end

defmodule TraysWeb.TestCurrentUserLive do
  @moduledoc false
  use Phoenix.LiveView

  # Hook to convert current_scope to current_user before authorization
  on_mount TraysWeb.TestCurrentUserLive.SetCurrentUser
  on_mount {TraysWeb.Hooks.Authorize, {:manage, :menu}}

  def render(assigns) do
    ~H"""
    <div>Current User Content</div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  defmodule SetCurrentUser do
    def on_mount(_name, _params, _session, socket) do
      socket =
        case socket.assigns do
          %{current_scope: %{user: user}} ->
            socket
            |> Phoenix.Component.assign(:current_user, user)
            |> Phoenix.Component.assign(:current_scope, nil)

          _ ->
            socket
        end

      {:cont, socket}
    end
  end
end

defmodule TraysWeb.TestNoUserLive do
  @moduledoc false
  use Phoenix.LiveView

  # Hook to remove all user assignments before authorization
  on_mount TraysWeb.TestNoUserLive.RemoveUser
  on_mount {TraysWeb.Hooks.Authorize, {:manage, :menu}}

  def render(assigns) do
    ~H"""
    <div>No User Content</div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  defmodule RemoveUser do
    def on_mount(_name, _params, _session, socket) do
      # Remove user assigns entirely to trigger the _ -> nil pattern
      assigns =
        socket.assigns
        |> Map.delete(:current_scope)
        |> Map.delete(:current_user)

      socket = %{socket | assigns: assigns}

      {:cont, socket}
    end
  end
end
