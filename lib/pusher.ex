defmodule Pusher do
  alias Pusher.HttpClient

  @doc """
  Trigger a simple `event` on `channels` sending some `data`
  """
  def trigger(client, event, data, channels, socket_id \\ nil) do
    data = encoded_data(data)

    body =
      event_body(event, data, channels, socket_id)
      |> Jason.encode!()

    headers = %{"Content-type" => "application/json"}

    case HttpClient.post("/apps/#{client.app_id}/events", body, headers, client: client) do
      {:ok, %HTTPoison.Response{status_code: 200}} -> :ok
      {:ok, response} -> {:error, response}
      {:error, reason} -> {:error, reason}
    end
  end

  defp event_body(event, data, channels, nil) do
    %{name: event, channels: channel_list(channels), data: data}
  end

  defp event_body(event, data, channels, socket_id) do
    event_body(event, data, channels, nil)
    |> Map.put(:socket_id, socket_id)
  end

  @doc """
  Get the list of occupied channels
  """
  def channels(client) do
    case HttpClient.get("/apps/#{client.app_id}/channels", [], client: client) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} -> {:ok, body["channels"]}
      {:ok, response} -> {:error, response}
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Get info related to the `channel`
  """
  def channel(client, channel) do
    path = "/apps/#{client.app_id}/channels/#{channel}"

    case HttpClient.get(path, %{}, qs: %{info: "subscription_count"}, client: client) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} -> {:ok, body}
      {:ok, response} -> {:error, response}
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Get the list of users on the prensece `channel`
  """
  def users(client, channel) do
    path = "/apps/#{client.app_id}/channels/#{channel}/users"

    case HttpClient.get(path, [], client: client) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} -> {:ok, body["users"]}
      {:ok, response} -> {:error, response}
      {:error, reason} -> {:error, reason}
    end
  end

  defp channel_list(channels) when is_list(channels), do: channels
  defp channel_list(channel), do: [channel]

  defp encoded_data(data) when is_binary(data), do: data
  defp encoded_data(data), do: Jason.encode!(data)
end
