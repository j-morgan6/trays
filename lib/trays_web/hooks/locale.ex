defmodule TraysWeb.Hooks.Locale do
  @moduledoc """
  LiveView hook that sets the locale based on the session or query parameters.
  """
  import Phoenix.Component

  def on_mount(:default, params, session, socket) do
    locale = params["locale"] || session["locale"] || "en"
    Gettext.put_locale(TraysWeb.Gettext, locale)

    {:cont, assign(socket, :locale, locale)}
  end
end
