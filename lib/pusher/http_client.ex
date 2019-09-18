defmodule Pusher.HttpClient do
  use HTTPoison.Base
  alias Pusher.RequestSigner
  alias Pusher.Client

  def process_response_body(body) do
    case Jason.decode(body) do
      {:ok, response} -> response
      {:error, _reason} -> body
    end
  end

  @doc """
  More info at: http://pusher.com/docs/rest_api#authentication
  """
  def request(method, path, body \\ "", headers \\ [], options \\ []) do
    client = Keyword.get(options, :client, %Client{})

    query_string =
      Keyword.get(options, :qs, %{})
      |> RequestSigner.sign_query_string(body, client.app_key, client.secret, method, path)
      |> URI.encode_query()

    super(method, "#{client.endpoint}#{path}?#{query_string}", body, headers, options)
  end
end
