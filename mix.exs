defmodule Pusher.Mixfile do
  use Mix.Project

  @description """
    Pusher HTTP client
  """

  def project do
    [
      app: :pusher,
      version: "2.2.1",
      elixir: "~> 1.7",
      name: "Pusher",
      description: @description,
      package: package(),
      source_url: "https://github.com/edgurgel/pusher",
      deps: deps(),
      docs: [
        main: "readme",
        extras: ["README.md"]
      ]
    ]
  end

  def application do
    []
  end

  defp deps do
    [
      {:httpoison, "~> 1.0"},
      {:signaturex, "~> 1.4"},
      {:jason, "~> 1.0"},
      {:websockex, "~> 0.4.0"},
      {:mimic, "~> 1.0", only: :test},
      {:ex_doc, "~> 0.19", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      maintainers: ["Eduardo Gurgel Pinho", "Bernat Jufré"],
      licenses: ["MIT"],
      links: %{"Github" => "https://github.com/edgurgel/pusher"}
    ]
  end
end
