defmodule Pusher.Mixfile do
  use Mix.Project

  def project do
    [ app: :pusher,
      version: "0.0.1",
      elixir: "~> 0.15.0 or ~> 1.0.0",
      deps: deps ]
  end

   def application do
    [
      applications: [ :httpoison, :jsex ],
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
    [ {:httpoison, "~> 0.4.0"},
      {:signaturex, "~> 0.0.7"},
      {:jsex, "~> 2.0"},
      {:meck, "~> 0.8.2", only: :test } ]
   end

end
