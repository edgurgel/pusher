defmodule Pusher.Mixfile do
  use Mix.Project

  def project do
    [ app: :pusher,
      version: "0.0.1",
      elixir: "~> 0.12.0",
      deps: deps(Mix.env) ]
  end

   def application do
    [
      applications: [ :httpoison, :jsex ],
      env: [
        host: "http://localhost",
        port: "8080",
        app_key: "app_key",
        app_secret: "secret",
        app_id: "app_id"
      ]
    ]
  end

  defp deps(:dev) do
    [
     {:httpoison, github: "edgurgel/httpoison"},
     {:jsex, github: "talentdeficit/jsex", ref: "c9df36f07b2089a73ab6b32074c01728f1e5a2e1"},
    ]
   end

   defp deps(:docs) do
     deps(:dev) ++ [ {:ex_doc, github: "elixir-lang/ex_doc" } ]
   end

  defp deps(:test) do
    deps(:dev) ++ [ {:meck, github: "eproxus/meck", tag: "0.7.2" } ]
  end

  defp deps(_), do: deps(:dev)

end
