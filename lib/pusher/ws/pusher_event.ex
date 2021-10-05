defmodule Pusher.WS.PusherEvent do
  import Jason
  alias Pusher.WS.Credential
  alias Pusher.WS.User

  @doc """
  Returns JSON for a client `event` on `channel` sending `data`
  """
  def client_event(event, data, channel) do
    %{event: event, data: data, channel: channel} |> encode!
  end

  @doc """
  Return a JSON for a subscription request using the `channel` name as parameter
  """
  @spec subscribe(binary) :: binary
  def subscribe(channel) do
    %{event: "pusher:subscribe", data: %{channel: channel}} |> encode!
  end

  @doc """
  Return a JSON for a subscription request using the private `channel`, `socket_id`
  and the credential
  """
  def subscribe(channel, socket_id, %Credential{secret: secret, app_key: app_key}) do
    to_sign = socket_id <> ":" <> channel
    auth = app_key <> ":" <> hmac256(secret, to_sign)
    %{event: "pusher:subscribe", data: %{channel: channel, auth: auth}} |> encode!
  end

  @doc """
  Return a JSON for a subscription request using the presence `channel`, `socket_id`,
  the `credential` and the `user`
  """
  def subscribe(channel, socket_id, %Credential{secret: secret, app_key: app_key}, %User{
        id: user_id,
        info: user_info
      }) do
    channel_data = %{user_id: user_id, user_info: user_info} |> encode!
    to_sign = socket_id <> ":" <> channel <> ":" <> channel_data
    auth = app_key <> ":" <> hmac256(secret, to_sign)

    %{
      event: "pusher:subscribe",
      data: %{channel: channel, auth: auth, channel_data: channel_data}
    }
    |> encode!
  end

  @doc """
  Return a JSON for a unsubscription request using the `channel` name as parameter
  """
  @spec unsubscribe(binary) :: binary
  def unsubscribe(channel) do
    %{event: "pusher:unsubscribe", data: %{channel: channel}} |> encode!
  end

  defp hmac256(app_secret, to_sign) do
    digest = if function_exported?(:crypto, :mac, 4),
      do: :crypto.mac(:hmac, :sha256, app_secret, to_sign),
      else: :crypto.hmac(:sha256, app_secret, to_sign)
      
    digest
    |> hexlify
    |> :string.to_lower()
    |> List.to_string()
  end

  defp hexlify(binary) do
    :lists.flatten(for b <- :erlang.binary_to_list(binary), do: :io_lib.format("~2.16.0B", [b]))
  end
end
