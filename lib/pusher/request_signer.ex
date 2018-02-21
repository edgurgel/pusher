defmodule Pusher.RequestSigner do
  alias Signaturex.CryptoHelper

  def sign_query_string(qs_vals, body, app_key, secret, method, path) do
    qs_vals
    |> add_body_md5(body)
    |> sign(app_key, secret, method, path)
  end

  def add_body_md5(qs_vals, ""), do: qs_vals

  def add_body_md5(qs_vals, body) do
    Map.put(qs_vals, :body_md5, CryptoHelper.md5_to_string(body))
  end

  defp sign(qs_vals, app_key, secret, method, path) do
    Signaturex.sign(app_key, secret, method, path, qs_vals)
    |> Map.merge(qs_vals)
  end
end
