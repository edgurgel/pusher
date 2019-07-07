# Pusher [![Build Status](https://travis-ci.org/edgurgel/pusher.png?branch=master)](https://travis-ci.org/edgurgel/pusher) [![Hex pm](http://img.shields.io/hexpm/v/pusher.svg?style=flat)](https://hex.pm/packages/pusher)
## Description

Elixir library to access the Pusher REST API.

## Usage

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
