defmodule Pusher.Mixfile do
  use Mix.Project

  @description """
    Pusher HTTP client
  """

  def project do
    [
      app: :pusher,
      version: "1.0.0",
      elixir: "~> 1.5",
      name: "Pusher",
      description: @description,
      package: package(),
      source_url: "https://github.com/edgurgel/pusher",
      deps: deps()
    ]
  end

  def application do
    [
      applications: [:httpoison, :exjsx, :signaturex],
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
    [
      {:httpoison, "~> 1.0"},
      {:signaturex, "~> 1.3.0"},
      {:exjsx, "~> 4.0.0"},
      {:mock, "~> 0.3.0", only: [:dev, :test]},
      {:ex_doc, "~> 0.16", only: :dev, runtime: false},
      {:earmark, ">= 1.2.3", only: :dev, runtime: false}
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
