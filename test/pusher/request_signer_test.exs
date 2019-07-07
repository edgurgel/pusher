defmodule Pusher.RequestSignerTest do
  use ExUnit.Case, async: true
  import Pusher.RequestSigner
  use Mimic

  @frozen_time 1_353_088_179

  describe "sign_query_string" do
    test "signs as expected" do
      stub(Signaturex.Time, :stamp, fn -> @frozen_time end)

      qs_vals = %{"some" => "value"}

      body =
        %{"name" => "foo", "channels" => ["project-3"], "data" => %{"some" => "data"}}
        |> Jason.encode!()

      key = "278d425bdf160c739803"
      secret = "7ad3773142a6692b25b8"
      method = :post
      path = "http://api.pusherapp.com/apps/3/events"

      expected_result = %{
        "some" => "value",
        :body_md5 => "5b37e2cd4b837a97b90ad2098f3c51c1",
        "auth_key" => key,
        "auth_signature" => "e79fb000a4d4e6086398738fa884b9d68991c02c89d62eb2278e9f8ed3aa2bc4",
        "auth_timestamp" => @frozen_time,
        "auth_version" => "1.0"
      }

      result = sign_query_string(qs_vals, body, key, secret, method, path)
      assert result == expected_result
    end
  end
end
