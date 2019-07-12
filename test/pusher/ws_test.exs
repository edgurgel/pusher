defmodule Pusher.WSTest do
  use ExUnit.Case
  alias Pusher.WS.PusherEvent
  alias Pusher.WS.State
  alias Pusher.WS.Credential
  alias Pusher.WS.User
  import Pusher.WS
  use Mimic

  describe("handle_connect/2") do
    test "init" do
      credential = %Credential{app_key: "key", secret: "secret"}

      assert {:ok, %State{stream_to: nil, credential: ^credential}} =
               handle_connect(:conn, ["key", "secret", []])
    end
  end

  describe "start_link/4" do
    test "start websocket connection" do
      app_key = "app_key"
      secret = "secret"
      options = [stream_to: self()]
      url = "ws://websocket.example"
      ws_url = "ws://websocket.example/app/app_key?protocol=7"

      expect(WebSockex, :start_link, fn ^ws_url, Pusher.WS, [^app_key, ^secret, ^options] ->
        :ok
      end)

      assert :ok == start_link(url, app_key, secret, options)
    end
  end

  describe "handle_frame/2" do
    test "handle connection established event" do
      state = %State{stream_to: self()}
      socket_id = "87381"

      event =
        %{
          "event" => "pusher:connection_established",
          "data" => %{"socket_id" => socket_id}
        }
        |> Jason.encode!()

      assert handle_frame({:text, event}, state) ==
               {:ok, %State{stream_to: self(), socket_id: socket_id}}
    end

    test "handle subscription succeeded event" do
      state = %State{stream_to: self()}
      channel = "public-channel"

      event =
        %{
          "event" => "pusher_internal:subscription_succeeded",
          "channel" => channel,
          "data" => %{}
        }
        |> Jason.encode!()

      assert handle_frame({:text, event}, state) == {:ok, state}

      assert_receive %{
        channel: "public-channel",
        event: "pusher:subscription_succeeded",
        data: %{}
      }
    end

    test "handle other events with encoded data" do
      state = %State{stream_to: self()}
      channel = "public-channel"

      event =
        %{
          "event" => "message",
          "channel" => channel,
          "data" => Jason.encode!(%{"etc" => "anything"})
        }
        |> Jason.encode!()

      assert handle_frame({:text, event}, state) == {:ok, state}
      assert_receive %{channel: "public-channel", event: "message", data: %{"etc" => "anything"}}
    end

    test "handle other events with non encoded data" do
      state = %State{stream_to: self()}
      channel = "public-channel"

      event =
        %{
          "event" => "message",
          "channel" => channel,
          "data" => %{"etc" => "anything"}
        }
        |> Jason.encode!()

      assert handle_frame({:text, event}, state) == {:ok, state}
      assert_receive %{channel: "public-channel", event: "message", data: %{"etc" => "anything"}}
    end
  end

  describe "handle_cast/2" do
    test "subscribe to a public channel" do
      state = %State{}
      channel = "channel"

      event = PusherEvent.subscribe(channel)

      assert handle_cast({:subscribe, channel}, state) == {:reply, {:text, event}, state}
    end

    test "subscribe to a private channel" do
      credential = %Credential{app_key: "key", secret: "secret"}
      socket_id = "123"
      channel = "private-channel"

      state = %State{socket_id: socket_id, credential: credential}

      event = PusherEvent.subscribe(channel, socket_id, credential)

      assert handle_cast({:subscribe, channel}, state) == {:reply, {:text, event}, state}
    end

    test "subscribe to a presence channel" do
      credential = %Credential{app_key: "key", secret: "secret"}
      user = %User{id: "123", info: %{}}
      socket_id = "123"
      channel = "presence-channel"

      state = %State{socket_id: socket_id, credential: credential}

      event = PusherEvent.subscribe(channel, socket_id, credential, user)

      assert handle_cast({:subscribe, channel, user}, state) == {:reply, {:text, event}, state}
    end

    test "unsubscribe from a channel" do
      state = %State{}
      channel = "channel"

      event = PusherEvent.unsubscribe(channel)

      assert handle_cast({:unsubscribe, channel}, state) == {:reply, {:text, event}, state}
    end

    test "trigger client event" do
      state = %State{}
      channel = "channel"
      client_event = "client-event"
      data = %{"a" => "b"}

      event = PusherEvent.client_event(client_event, data, channel)

      assert handle_cast(
               {:trigger_event, client_event, data, channel},
               state
             ) == {:reply, {:text, event}, state}
    end
  end

  describe "terminate/2" do
    test "terminating with error code 4001" do
      state = %State{}

      assert terminate({:remote, 4001, "Message"}, state) == :ok
    end

    test "terminating with error code 4007" do
      state = %State{}

      assert terminate({:remote, 4007, "Message"}, state) == :ok
    end

    test "terminating normally" do
      assert terminate({:normal, "Message"}, nil) == :ok
    end
  end
end
