defmodule Pusher do
  alias Pusher.HttpClient

  @doc """
  Trigger a simple `event` on `channels` sending some `data`
  """
  def trigger(event, data, channels, socket_id \\ nil) do
    data = encoded_data(data)

    body =
      event_body(event, data, channels, socket_id)
      |> JSX.encode!()

    headers = %{"Content-type" => "application/json"}
    response = HttpClient.post!("/apps/#{app_id()}/events", body, headers)

    if response_success?(response) do
      :ok
    else
      :error
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
  def channels do
    response = HttpClient.get!("/apps/#{app_id()}/channels")

    if response_success?(response) do
      {:ok, response.body["channels"]}
    else
      {:error, response.body}
    end
  end

  @doc """
  Get info related to the `channel`
  """
  def channel(channel) do
    response =
      HttpClient.get!(
        "/apps/#{app_id()}/channels/#{channel}",
        %{},
        qs: %{info: "subscription_count"}
      )

    if response_success?(response) do
      {:ok, response.body}
    else
      {:error, response.body}
    end
  end

  @doc """
  Get the list of users on the prensece `channel`
  """
  def users(channel) do
    response = HttpClient.get!("/apps/#{app_id()}/channels/#{channel}/users")

    if response_success?(response) do
      {:ok, response.body["users"]}
    else
      {:error, response.body}
    end
  end

  def configure!(host, port, app_id, app_key, secret) do
    :application.set_env(:pusher, :host, host)
    :application.set_env(:pusher, :port, port)
    :application.set_env(:pusher, :app_id, app_id)
    :application.set_env(:pusher, :app_key, app_key)
    :application.set_env(:pusher, :secret, secret)
  end

  defp channel_list(channels) when is_list(channels), do: channels
  defp channel_list(channel), do: [channel]

  defp encoded_data(data) when is_binary(data), do: data
  defp encoded_data(data), do: JSX.encode!(data)

  defp app_id do
    {:ok, app_id} = :application.get_env(:pusher, :app_id)
    app_id
  end

  defp response_success?(response), do: response.status_code == 200
end
