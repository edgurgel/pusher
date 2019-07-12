defmodule Pusher.WS do
  @moduledoc """
  Websocket Handler based on the Pusher Protocol: http://pusher.com/docs/pusher_protocol
  """
  alias Pusher.WS.PusherEvent
  use WebSockex
  require Logger

  @protocol 7

  defmodule User do
    defstruct id: nil, info: %{}
  end

  defmodule Credential do
    defstruct app_key: "app_key", secret: "secret"
  end

  defmodule State do
    defstruct stream_to: nil, socket_id: nil, credential: %Credential{}
  end

  defmodule ClientEvent do
    defstruct [:event, :channel, :data]
  end

  def start_link(url, app_key, secret, options \\ [])

  def start_link(url, app_key, secret, options) do
    url = build_url(url, app_key)
    WebSockex.start_link(url, __MODULE__, [app_key, secret, options])
  end

  defp build_url(url, app_key) do
    query = "?" <> URI.encode_query(%{protocol: @protocol})
    url <> "/app/" <> app_key <> query
  end

  def subscribe!(pid, channel) when is_pid(pid) do
    WebSockex.cast(pid, {:subscribe, channel})
  end

  def subscribe!(pid, channel, user = %User{}) when is_pid(pid) do
    WebSockex.cast(pid, {:subscribe, channel, user})
  end

  def unsubscribe!(pid, channel), do: WebSockex.cast(pid, {:unsubscribe, channel})

  def disconnect!(pid), do: WebSockex.cast(pid, :stop)

  def trigger_event!(pid, "client-" <> _ = event, data, channel) do
    WebSockex.cast(pid, {:trigger_event, event, data, channel})
  end

  def handle_connect(_conn, [app_key, secret, options]) do
    stream_to = Keyword.get(options, :stream_to, nil)
    credential = %Credential{app_key: app_key, secret: secret}
    {:ok, %State{stream_to: stream_to, credential: credential}}
  end

  def handle_frame({:text, event}, state) do
    event = Jason.decode!(event)
    handle_event(event["event"], event, state)
  end

  @doc false
  def handle_cast({:subscribe, channel = "private-" <> _}, state) do
    event = PusherEvent.subscribe(channel, state.socket_id, state.credential)
    {:reply, {:text, event}, state}
  end

  def handle_cast({:subscribe, channel = "presence-" <> _, user}, state) do
    event = PusherEvent.subscribe(channel, state.socket_id, state.credential, user)
    {:reply, {:text, event}, state}
  end

  def handle_cast({:subscribe, channel}, state) do
    event = PusherEvent.subscribe(channel)
    {:reply, {:text, event}, state}
  end

  def handle_cast({:unsubscribe, channel}, state) do
    event = PusherEvent.unsubscribe(channel)
    {:reply, {:text, event}, state}
  end

  def handle_cast({:trigger_event, event, data, channel}, state) do
    event = PusherEvent.client_event(event, data, channel)
    {:reply, {:text, event}, state}
  end

  def handle_cast(:stop, _state), do: {:close, nil}

  def handle_cast(_msg, state), do: {:ok, state}

  @doc false
  def terminate({_close, 4001, _message} = reason, state) do
    Logger.error("Wrong app_key")
    do_terminate(reason, state)
  end

  def terminate({_close, 4007, _message} = reason, state) do
    Logger.error("Pusher server does not support current protocol #{@protocol}")
    do_terminate(reason, state)
  end

  def terminate({_close, code, payload} = reason, state) do
    Logger.info("Websocket close with code #{code} and payload '#{payload}'.")
    do_terminate(reason, state)
  end

  def terminate({:normal, _message}, nil), do: :ok

  def terminate(reason, state) do
    do_terminate(reason, state)
  end

  def do_terminate(_reason, _state), do: :ok

  @doc false
  defp handle_event(event_name = "pusher:connection_established", event, state) do
    socket_id = fetch_data(event["data"])["socket_id"]
    notify(state.stream_to, event, event_name)
    {:ok, %{state | socket_id: socket_id}}
  end

  defp handle_event("pusher_internal:subscription_succeeded", event, state) do
    notify(state.stream_to, event, "pusher:subscription_succeeded")
    {:ok, state}
  end

  defp handle_event(event_name, event, state) do
    notify(state.stream_to, event, event_name)
    {:ok, state}
  end

  defp notify(nil, _, _), do: :ok

  defp notify(stream_to, event, name) do
    send(stream_to, %{event: name, channel: event["channel"], data: fetch_data(event["data"])})
  end

  defp fetch_data(data) when is_map(data), do: data
  defp fetch_data(data), do: Jason.decode!(data)
end
