defmodule PusherTest do
  use ExUnit.Case, async: true
  use Mimic
  alias Pusher.{Client, HttpClient}

  setup do
    stub(HttpClient)
    :ok
  end

  @client %Client{app_id: "le_app_id"}

  @response_succesful %HTTPoison.Response{
    body: %{},
    status_code: 200
  }

  @payload %{name: "event-name", channels: ["channel"], data: "data"} |> Jason.encode!()

  @payload_with_socket_id %{
                            name: "event-name",
                            channels: ["channel"],
                            data: "data",
                            socket_id: "blah"
                          }
                          |> Jason.encode!()

  describe "trigger/4" do
    test "successful request" do
      expect(HttpClient, :post, fn "/apps/le_app_id/events", @payload, _, [client: @client] ->
        {:ok, @response_succesful}
      end)

      assert Pusher.trigger(@client, "event-name", "data", "channel") == :ok
    end

    test "unsuccessful request" do
      response = %HTTPoison.Response{status_code: 400}

      expect(HttpClient, :post, fn "/apps/le_app_id/events", @payload, _, [client: @client] ->
        {:ok, response}
      end)

      assert Pusher.trigger(@client, "event-name", "data", "channel") == {:error, response}
    end

    test "request error" do
      expect(HttpClient, :post, fn "/apps/le_app_id/events", @payload, _, [client: @client] ->
        {:error, :reason}
      end)

      assert Pusher.trigger(@client, "event-name", "data", "channel") == {:error, :reason}
    end

    test "sends the payload with a socket_id" do
      expect(HttpClient, :post, fn "/apps/le_app_id/events",
                                   @payload_with_socket_id,
                                   _,
                                   [client: @client] ->
        {:ok, @response_succesful}
      end)

      assert Pusher.trigger(@client, "event-name", "data", "channel", "blah") == :ok
    end
  end

  @response_with_channel %HTTPoison.Response{
    body: %{"channels" => %{"test_channel" => %{}}},
    status_code: 200
  }

  describe "channels/1" do
    test "successful request" do
      expect(HttpClient, :get, fn "/apps/le_app_id/channels", [], [client: @client] ->
        {:ok, @response_with_channel}
      end)

      assert Pusher.channels(@client) == {:ok, %{"test_channel" => %{}}}
    end

    test "unsuccessful request" do
      response = %HTTPoison.Response{status_code: 400}

      expect(HttpClient, :get, fn "/apps/le_app_id/channels", [], [client: @client] ->
        {:ok, response}
      end)

      assert Pusher.channels(@client) == {:error, response}
    end

    test "request error" do
      expect(HttpClient, :get, fn "/apps/le_app_id/channels", [], [client: @client] ->
        {:error, :reason}
      end)

      assert Pusher.channels(@client) == {:error, :reason}
    end
  end

  @response_with_channel_info %HTTPoison.Response{
    body: %{"occupied" => true, "user_count" => 42},
    status_code: 200
  }

  describe "channel/2" do
    test "channel with an argument returns the user count for the channel" do
      expect(HttpClient, :get, fn "/apps/le_app_id/channels/test_info_channel",
                                  %{},
                                  qs: %{info: "subscription_count"},
                                  client: @client ->
        {:ok, @response_with_channel_info}
      end)

      assert Pusher.channel(@client, "test_info_channel") ==
               {:ok, %{"occupied" => true, "user_count" => 42}}
    end

    test "unsuccessful request" do
      response = %HTTPoison.Response{status_code: 400}

      expect(HttpClient, :get, fn "/apps/le_app_id/channels/test_info_channel",
                                  %{},
                                  qs: %{info: "subscription_count"},
                                  client: @client ->
        {:ok, response}
      end)

      assert Pusher.channel(@client, "test_info_channel") == {:error, response}
    end

    test "request error" do
      expect(HttpClient, :get, fn "/apps/le_app_id/channels/test_info_channel",
                                  %{},
                                  qs: %{info: "subscription_count"},
                                  client: @client ->
        {:error, :reason}
      end)

      assert Pusher.channel(@client, "test_info_channel") == {:error, :reason}
    end
  end

  @response_with_users %HTTPoison.Response{
    body: %{"users" => [%{"id" => 3}, %{"id" => 57}]},
    status_code: 200
  }

  describe "users/2" do
    test "returns users in a presence channel" do
      expect(HttpClient, :get, fn "/apps/le_app_id/channels/presence-foobar/users",
                                  [],
                                  client: @client ->
        {:ok, @response_with_users}
      end)

      assert Pusher.users(@client, "presence-foobar") == {:ok, [%{"id" => 3}, %{"id" => 57}]}
    end

    test "unsuccessful request" do
      response = %HTTPoison.Response{status_code: 400}

      expect(HttpClient, :get, fn "/apps/le_app_id/channels/presence-foobar/users",
                                  [],
                                  client: @client ->
        {:ok, response}
      end)

      assert Pusher.users(@client, "presence-foobar") == {:error, response}
    end

    test "request error" do
      expect(HttpClient, :get, fn "/apps/le_app_id/channels/presence-foobar/users",
                                  [],
                                  client: @client ->
        {:error, :reason}
      end)

      assert Pusher.users(@client, "presence-foobar") == {:error, :reason}
    end
  end
end
