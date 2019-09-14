defmodule Pusher.HttpClientTest do
  use ExUnit.Case, async: true
  alias Pusher.HttpClient

  describe "process_response_body/1" do
    test "json body" do
      channels_response = """
      {
        "channels": {
          "presence-foobar": {
            "user_count": 42
          }
        }
      }
      """

      expected = %{
        "channels" => %{
          "presence-foobar" => %{
            "user_count" => 42
          }
        }
      }

      assert HttpClient.process_response_body(channels_response) == expected
    end

    test "invalid body" do
      assert HttpClient.process_response_body("404 NOT FOUND\n") == "404 NOT FOUND\n"
    end

    test "empty body" do
      assert HttpClient.process_response_body("") == ""
    end
  end
end
