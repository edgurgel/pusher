defmodule PusherTest do
  use ExUnit.Case
  import Mock
  import Pusher

  test "configure! should change application env" do
    configure!("host", "port", "app_id", "app_key", "secret")
    vars = :application.get_all_env(:pusher)

    assert vars[:host]    == "host"
    assert vars[:port]    == "port"
    assert vars[:app_id]  == "app_id"
    assert vars[:app_key] == "app_key"
    assert vars[:secret]  == "secret"
  end

  @response_succesful_message %HTTPoison.Response{
    body: %{},
    status_code: 200
  }

  @expected_payload %{
    name: "event-name",
    channels: ["channel"],
    data: "data"
  } |> JSX.encode!

  test_with_mock ".trigger sends the payload to a single channel", Pusher.HttpClient,
  [post!: fn("/apps/app_id/events", @expected_payload, _) -> @response_succesful_message end] do
    :application.set_env(:pusher, :app_id, "app_id")
    result = Pusher.trigger("event-name", "data", "channel")
    expected = 200
    assert result == expected
  end

  @response_with_channel %HTTPoison.Response{
    body: %{"channels" => %{"test_channel" => %{}}},
    status_code: 200
  }

  test_with_mock ".channels calls the http client for list of channels", Pusher.HttpClient,
  [get!: fn("/apps/app_id/channels") -> @response_with_channel end] do
    :application.set_env(:pusher, :app_id, "app_id")
    result = Pusher.channels
    expected = {200, %{"channels" => %{"test_channel" => %{}}}}
    assert result == expected
  end


  @response_with_channel_info %HTTPoison.Response{
    body: %{"occupied" => true, "user_count" => 42},
    status_code: 200
  }

  test_with_mock ".channel with an argument returns the user count for the channel", Pusher.HttpClient,
  [get!: fn("/apps/app_id/channels/test_info_channel", %{}, qs: %{info: "subscription_count"}) -> @response_with_channel_info end] do
    :application.set_env(:pusher, :app_id, "app_id")
    result = Pusher.channel "test_info_channel"
    expected = {200, %{"occupied" => true, "user_count" => 42}}
    assert result == expected
  end

  @response_with_users %HTTPoison.Response{
    body: %{"users" => [%{"id" => 3}, %{"id" => 57}]},
    status_code: 200
  }

  test_with_mock ".users returns users in a presence channel", Pusher.HttpClient,
  [get!: fn("/apps/app_id/channels/presence-foobar/users") -> @response_with_users end] do
    :application.set_env(:pusher, :app_id, "app_id")
    result = Pusher.users "presence-foobar"
    expected = {200, %{"users" => [%{"id" => 3}, %{"id" => 57}]}}
    assert result == expected
  end

end
