defmodule Pusher.Mixfile do
  use Mix.Project

  @description """
    Pusher HTTP client
  """

  def project do
    [ app: :pusher,
      version: "0.0.1",
      elixir: "~> 1.0.0",
      name: "Pusher",
      description: @description,
      package: package,
      deps: deps ]
  end

   def application do
    [
      applications: [ :httpoison, :exjsx ],
      env: [
        host: "http://localhost",
        port: "8080",
        app_key: "app_key",
        app_id: "app_id",
        secret: "secret"
      ]
    ]
  end

  defp deps do
    [ {:httpoison, "~> 0.6.0"},
      {:signaturex, "~> 0.0.7"},
      {:exjsx, "~> 3.0"},
      {:meck, "~> 0.8.2", only: :test } ]
   end

   defp package do
     [ contributors: ["Eduardo Gurgel Pinho"],
       licenses: ["MIT"],
       links: %{"Github" => "https://github.com/edgurgel/pusher"} ]
   end
end
