# Pusher [![Build Status](https://travis-ci.org/edgurgel/pusher.png?branch=master)](https://travis-ci.org/edgurgel/pusher)

## Description

Elixir library to access the Pusher REST API.

## Usage

```elixir
Pusher.trigger("message", [text: "Hello!"], "chat-channel")
```
## TODO

* How to configure` app_id`, `secret`, `app_key`, `host` and `port`
* Add tests
* Add support to `/channels`, `/channels/:channel_name`, etc
