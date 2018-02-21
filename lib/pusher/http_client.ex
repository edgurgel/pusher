defmodule Pusher.HttpClient do
  use HTTPoison.Base
  alias Pusher.RequestSigner

  defp process_url(url), do: base_url() <> url

  defp base_url do
    {:ok, host} = :application.get_env(:pusher, :host)
    {:ok, port} = :application.get_env(:pusher, :port)
    "#{host}:#{port}"
  end

  defp process_response_body(body) do
    unless body == "", do: body |> JSX.decode!(), else: nil
  end

  @doc """
  More info at: http://pusher.com/docs/rest_api#authentication
  """
  def request(method, path, body \\ "", headers \\ [], options \\ []) do
    query_string =
      Keyword.get(options, :qs, %{})
      |> RequestSigner.sign_query_string(body, app_key(), secret(), method, path)
      |> URI.encode_query()

    super(method, path <> "?" <> query_string, body, headers, options)
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
