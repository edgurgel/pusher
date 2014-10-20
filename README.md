# Pusher [![Build Status](https://travis-ci.org/edgurgel/pusher.png?branch=master)](https://travis-ci.org/edgurgel/pusher)

## Description

Elixir library to access the Pusher REST API.

## Usage

```elixir
Pusher.configure!("localhost", 8080, "app_id", "app_key", "secret")
```

```elixir
Pusher.trigger("message", [text: "Hello!"], "chat-channel")
```

To get occupied channels:

```elixir
Pusher.channels
```

To get users connected to a presence channel

```elixir
Pusher.users("presence-demo")
```

## TODO

* Add tests
