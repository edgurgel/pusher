defmodule Pusher do
  use HTTPoison.Base

  alias Signaturex.CryptoHelper

  @doc """
  Trigger a simple `event` on a `channel` sending some `data`
  """
  def trigger(event, data, channel) do
    body = JSEX.encode!([name: event, channel: channel, data: data])
    headers = %{"Content-type" => "application/json"}
    response = post!("/apps/#{app_id}/events", body, headers)
    response.status_code
  end

  @doc """
  Get the list of occupied channels
  """
  def channels do
    response = get!("/apps/#{app_id}/channels")

    {response.status_code, response.body}
  end

  @doc """
  Get info related to the `channel`
  """
  def channel(channel) do
    response = get!("/apps/#{app_id}/channels/#{channel}", %{}, qs: %{info: "subscription_count"})

    {response.status_code, response.body}
  end

  @doc """
  Get the list of users on the prensece `channel`
  """
  def users(channel) do
    response = get!("/apps/#{app_id}/channels/#{channel}/users")

    {response.status_code, response.body}
  end

  defp process_url(url), do: base_url <> url

  defp base_url do
    {:ok, host} = :application.get_env(:pusher, :host)
    {:ok, port} = :application.get_env(:pusher, :port)
    "#{host}:#{port}"
  end

  defp process_response_body(body) do
    unless body == "", do: body |> JSEX.decode!, else: nil
  end

  @doc """
  More info at: http://pusher.com/docs/rest_api#authentication
  """
  def request(method, path, body \\ "", headers \\ [], options \\ []) do
    qs_vals = build_qs(Keyword.get(options, :qs, %{}), body)
    signed_qs_vals =
      Signaturex.sign(app_key, secret, method, path, qs_vals)
      |> Dict.merge(qs_vals)
      |> URI.encode_query
    super(method, path <> "?" <> signed_qs_vals, body, headers, options)
  end

  def build_qs(qs_vals, ""), do: qs_vals
  def build_qs(qs_vals, body) do
    Map.put(qs_vals, :body_md5, CryptoHelper.md5_to_string(body))
  end

  def configure!(host, port, app_id, app_key, secret) do
    :application.set_env(:pusher, :host, host)
    :application.set_env(:pusher, :port, port)
    :application.set_env(:pusher, :app_id, app_id)
    :application.set_env(:pusher, :app_key, app_key)
    :application.set_env(:pusher, :secret, secret)
  end

  defp app_id do
    {:ok, app_id} = :application.get_env(:pusher, :app_id)
    app_id
  end

  defp secret do
    {:ok, secret} = :application.get_env(:pusher, :secret)
    secret
  end

  defp app_key do
    {:ok, app_key} = :application.get_env(:pusher, :app_key)
    app_key
  end
end
