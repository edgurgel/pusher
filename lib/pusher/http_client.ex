defmodule Pusher.HttpClient do
  use HTTPoison.Base
  alias Signaturex.CryptoHelper

  defp process_url(url), do: base_url <> url

  defp base_url do
    {:ok, host} = :application.get_env(:pusher, :host)
    {:ok, port} = :application.get_env(:pusher, :port)
    "#{host}:#{port}"
  end

  defp process_response_body(body) do
    unless body == "", do: body |> JSX.decode!, else: nil
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

  defp secret do
    {:ok, secret} = :application.get_env(:pusher, :secret)
    secret
  end

  defp app_key do
    {:ok, app_key} = :application.get_env(:pusher, :app_key)
    app_key
  end

end
