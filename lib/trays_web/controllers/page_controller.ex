defmodule TraysWeb.PageController do
  use TraysWeb, :controller

  def home(conn, _params) do
    render(conn, :home, locale: conn.assigns.locale)
  end
end
