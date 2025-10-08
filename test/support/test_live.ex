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
