defmodule PusherTest do
  use ExUnit.Case
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
end
