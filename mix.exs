defmodule Pusher.Mixfile do
  use Mix.Project

  def project do
    [ app: :pusher,
      version: "0.0.1",
      elixir: "~> 0.10.2",
      deps: deps(Mix.env) ]
  end

   def application do
    [
      applications: [ :hackney, :jsex ],
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
     {:hackney, github: "benoitc/hackney"},
     {:jsex, github: "talentdeficit/jsex"},
     {:uri, github: "erlware/uri"},
     {:erlsha2, github: "vinoski/erlsha2" }
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
