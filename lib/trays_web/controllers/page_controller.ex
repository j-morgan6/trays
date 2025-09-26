defmodule TraysWeb.PageController do
  use TraysWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
