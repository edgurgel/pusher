defmodule Pusher do
  alias Pusher.CryptoHelper
  def trigger(event, data, channel) do
    body = JSEX.encode!([name: event, channel: channel, data: data])
    headers = [{"Content-type", "application/json"}]
    {:ok, code, headers, client} = signed_request(:post, "/apps/#{app_id}/events", headers, body)
    code
  end

  defp base_url do
    {:ok, host} = :application.get_env(:pusher, :host)
    {:ok, port} = :application.get_env(:pusher, :port)
    "#{host}:#{port}"
  end

  # Check if body is empty
  defp signed_request(method, path, headers, body) do
    url = base_url <> path
    qs_vals = base_qs_vals ++ [
      body_md5: CryptoHelper.md5_to_binary(body)
    ]
    auth_signature = auth_signature(method, path, qs_vals)
    qs_vals = :uri.to_query(qs_vals ++ [auth_signature: auth_signature])
    :hackney.request(method, url <> "?" <> qs_vals, headers, body, [])
  end

  defp auth_signature(method, path, qs_vals) do
    to_sign = String.upcase(to_binary(method)) <> "\n" <> path <> "\n" <> :uri.to_query(qs_vals)
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
