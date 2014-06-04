defmodule Pusher.Mixfile do
  use Mix.Project

  def project do
    [ app: :pusher,
      version: "0.0.1",
      elixir: "~> 0.13.3",
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
    [ {:httpoison, github: "edgurgel/httpoison", tag: "0.1.1"},
      {:signaturex, "~> 0.0.3"},
      {:jsex, "~> 2.0"},
      {:meck, github: "eproxus/meck", tag: "0.8.2", only: :test } ]
   end

end
