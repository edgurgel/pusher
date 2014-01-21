defmodule Pusher do
  use HTTPoison.Base

  alias Pusher.CryptoHelper

  @doc """
  Trigger a simple `event` on a `channel` sending some `data`
  """
  def trigger(event, data, channel) do
    body = JSEX.encode!([name: event, channel: channel, data: data])
    headers = [{"Content-type", "application/json"}]
    response = post("/apps/#{app_id}/events", body, headers)
    response.status_code
  end

  def channels do
    headers = [{"Accept", "application/json"}]
    response = get("/apps/#{app_id}/channels", headers)

    {response.status_code, response.body}
  end

  def process_url(url) do
    base_url <> url
  end

  defp base_url do
    {:ok, host} = :application.get_env(:pusher, :host)
    {:ok, port} = :application.get_env(:pusher, :port)
    "#{host}:#{port}"
  end

  def process_response_body(body) do
    unless body == "", do: body |> JSEX.decode!, else: nil
  end

  @doc """
  More info at: http://pusher.com/docs/rest_api#authentication
  """
  def request(method, path, body // "", headers // [], options // []) do
    qs_vals = add_body_md5(base_qs_vals, body)
    auth_signature = auth_signature(method, path, qs_vals)
    qs_vals = URI.encode_query(qs_vals ++ [auth_signature: auth_signature])
    super(method, path <> "?" <> qs_vals, body, headers, options)
  end

  defp add_body_md5(qs_vals, ""), do: qs_vals
  defp add_body_md5(qs_vals, body) do
    qs_vals ++ [ body_md5: CryptoHelper.md5_to_string(body) ]
  end

  defp auth_signature(method, path, qs_vals) do
    to_sign = String.upcase(to_string(method)) <> "\n" <> path <> "\n" <> URI.encode_query(qs_vals)
    CryptoHelper.hmac256_to_binary(app_secret, to_sign)
  end

  defp base_qs_vals do
    [
      auth_key: app_key,
      auth_timestamp: timestamp,
      auth_version: "1.0"
    ]
  end

  defp timestamp do
    {mega, sec, _micro} = :os.timestamp()
    mega * 1000000 + sec
  end

  defp app_id do
    {:ok, app_id} = :application.get_env(:pusher, :app_id)
    app_id
  end

  defp app_secret do
    {:ok, app_secret} = :application.get_env(:pusher, :app_secret)
    app_secret
  end

  defp app_key do
    {:ok, app_key} = :application.get_env(:pusher, :app_key)
    app_key
  end
end
