defmodule Trays.Adapters.Resend do
  @moduledoc """
  Custom Swoosh adapter for Resend.
  """

  use Swoosh.Adapter, required_config: [:api_key]

  alias Swoosh.Email

  @base_url "https://api.resend.com"
  @api_version "2022-08-01"

  @spec deliver(Swoosh.Email.t(), nil | maybe_improper_list() | map()) ::
          {:error,
           {non_neg_integer(), binary()}
           | %{:__exception__ => true, :__struct__ => atom(), optional(atom()) => any()}}
          | {:ok, %{id: any()}}
  def deliver(%Email{} = email, config) do
    api_key = config[:api_key]

    body = email |> prepare_body() |> Jason.encode!()
    headers = prepare_headers(api_key)

    case Finch.build(:post, "#{@base_url}/emails", headers, body)
         |> Finch.request(Trays.Finch) do
      {:ok, %{status: status, body: response_body}} when status in 200..299 ->
        {:ok, %{id: Jason.decode!(response_body)["id"]}}

      {:ok, %{status: status, body: response_body}} ->
        {:error, {status, response_body}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp prepare_body(email) do
    %{
      from: prepare_recipient(email.from),
      to: Enum.map(email.to, &prepare_recipient/1),
      subject: email.subject
    }
    |> put_text(email)
    |> put_html(email)
    |> put_reply_to(email)
  end

  defp prepare_recipient({nil, email}), do: email
  defp prepare_recipient({"", email}), do: email

  defp prepare_recipient({name, email}) when is_binary(name) and name != "",
    do: "#{name} <#{email}>"

  defp prepare_recipient(email) when is_binary(email), do: email

  defp prepare_headers(api_key) do
    [
      {"Authorization", "Bearer #{api_key}"},
      {"Content-Type", "application/json"},
      {"X-Resend-Version", @api_version}
    ]
  end

  defp put_text(body, %{text_body: nil}), do: body
  defp put_text(body, %{text_body: text}), do: Map.put(body, :text, text)

  defp put_html(body, %{html_body: nil}), do: body
  defp put_html(body, %{html_body: html}), do: Map.put(body, :html, html)

  defp put_reply_to(body, %{reply_to: nil}), do: body

  defp put_reply_to(body, %{reply_to: reply}),
    do: Map.put(body, :reply_to, prepare_recipient(reply))
end
