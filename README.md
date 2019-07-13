# Pusher [![Build Status](https://travis-ci.org/edgurgel/pusher.png?branch=master)](https://travis-ci.org/edgurgel/pusher) [![Hex pm](http://img.shields.io/hexpm/v/pusher.svg?style=flat)](https://hex.pm/packages/pusher)
## Description

Elixir library to access the Pusher REST API.

## Usage

### Rest client

Define your Pusher.Client

```elixir
ciient = Pusher.Client%{app_id: "app_id", app_key: "app_key", secret: "my_secret"}
ciient = Pusher.Client%{endpoint: "https://my_custom_pusher:8080", app_id: "app_id", app_key: "app_key", secret: "my_secret"}
```

```elixir
Pusher.trigger(client, "message", %{ text: "Hello!" }, "chat-channel")
```

To get occupied channels:

```elixir
Pusher.channels(client)
```

To get users connected to a presence channel

```elixir
Pusher.users(client, "presence-demo")
```

### Websocket client

## Usage

```iex
iex> {:ok, pid} = Pusher.WS.start_link("ws://localhost:8080", "app_key", "secret", stream_to: self)
{:ok, #PID<0.134.0>}
iex> Pusher.WS.subscribe!(pid, "channel")
:ok
iex> Pusher.WS.subscribe!(pid, "presence-channel", %PusherClient.User{id: "123", info: %{a: "b"}})
:ok
```

```iex
# self will receive messages like this:
%{channel: nil,
  data: %{"activity_timeout" => 120,
    "socket_id" => "b388664a-3278-11e4-90df-7831c1bf9520"},
  event: "pusher:connection_established"}

%{channel: "channel", data: %{}, event: "pusher:subscription_succeeded"}
```

That's it!

You can disconnect too:

```iex
iex> Pusher.WS.disconnect!(pid)
:stop
```
