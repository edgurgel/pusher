defmodule Pusher.Mixfile do
  use Mix.Project

  @description """
    Pusher HTTP client
  """

  def project do
    [
      app: :pusher,
      version: "2.5.0",
      elixir: "~> 1.16",
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
      {:httpoison, "~> 2.0"},
      {:signaturex, "~> 1.4"},
      {:jason, "~> 1.0"},
      {:websockex, "~> 0.4.0"},
      {:mimic, "~> 1.0", only: :test},
      {:earmark, "~> 1.0", only: :dev},
      {:ex_doc, "~> 0.25", only: :dev}
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
