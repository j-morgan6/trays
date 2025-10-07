defmodule TraysWeb.Plugs.Locale do
  import Plug.Conn

  @locales Gettext.known_locales(TraysWeb.Gettext)

  def init(default), do: default

  def call(conn, default) do
    locale = fetch_locale(conn) || default
    Gettext.put_locale(TraysWeb.Gettext, locale)

    conn =
      if conn.params["locale"] do
        put_session(conn, :locale, locale)
      else
        conn
      end

    assign(conn, :locale, locale)
  end

  defp fetch_locale(conn) do
    conn.params["locale"] || get_session(conn, :locale) || extract_accept_language(conn)
  end

  defp extract_accept_language(conn) do
    conn
    |> get_req_header("accept-language")
    |> parse_accept_language_header()
  end

  defp parse_accept_language_header([value | _]) do
    value
    |> String.split(",")
    |> Enum.map(&parse_language_option/1)
    |> find_best_locale()
  end

  defp parse_accept_language_header(_), do: nil

  defp find_best_locale(options) do
    options
    |> Enum.sort_by(& &1.quality, :desc)
    |> Enum.find_value(fn %{tag: tag} -> tag in @locales && tag end)
  end

  defp parse_language_option(string) do
    case Regex.named_captures(~r/^\s?(?<tag>[\w\-]+)(?:;q=(?<quality>[\d\.]+))?$/i, string) do
      %{"tag" => tag, "quality" => quality} ->
        %{tag: tag, quality: parse_quality(quality)}

      _ ->
        %{tag: string, quality: 1.0}
    end
  end

  defp parse_quality(""), do: 1.0
  defp parse_quality(nil), do: 1.0

  defp parse_quality(value) do
    case Float.parse(value) do
      {quality, _} -> quality
      _ -> 1.0
    end
  end
end
