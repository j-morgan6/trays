defmodule TraysWeb.Plugs.Locale do
  import Plug.Conn

  @locales Gettext.known_locales(TraysWeb.Gettext)

  def init(default), do: default

  def call(conn, default) do
    locale = fetch_locale(conn) || default
    Gettext.put_locale(TraysWeb.Gettext, locale)
    assign(conn, :locale, locale)
  end

  defp fetch_locale(conn) do
    conn.params["locale"] || get_session(conn, :locale) || extract_accept_language(conn)
  end

  defp extract_accept_language(conn) do
    case get_req_header(conn, "accept-language") do
      [value | _] ->
        value
        |> String.split(",")
        |> Enum.map(&parse_language_option/1)
        |> Enum.sort(&(&1.quality > &2.quality))
        |> Enum.find(&Enum.member?(@locales, &1.tag))
        |> case do
          %{tag: tag} -> tag
          nil -> nil
        end

      _ ->
        nil
    end
  end

  defp parse_language_option(string) do
    captures = Regex.named_captures(~r/^\s?(?<tag>[\w\-]+)(?:;q=(?<quality>[\d\.]+))?$/i, string)

    quality =
      case Float.parse(captures["quality"] || "1.0") do
        {val, _} -> val
        _ -> 1.0
      end

    %{tag: captures["tag"], quality: quality}
  end
end
