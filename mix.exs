defmodule Preludex.MixProject do
  use Mix.Project

  def project do
    [
      app: :preludex,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: "Elixir SDK for Prelude",
      package: package()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Preludex.Application, []}
    ]
  end

  defp deps do
    [
      {:tesla, "~> 1.13.2"},
      {:finch, "~> 0.19.0"},
      {:jason, "~> 1.4.4"},
      {:ex_doc, "~> 0.29", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      name: "preludex",
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/efcasado/preludex",
        "Prelude Docs" => "https://docs.prelude.so/"
      }
    ]
  end
end
