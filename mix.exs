defmodule XmlEtl.MixProject do
  use Mix.Project

  def project do
    [
      app: :xml_etl,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      escript: escript()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpoison, "~> 2.0"},
      {:jason, "~> 1.4"},
      {:dotenv, "~> 3.0.0"}
    ]
  end

  defp escript do
    [
      main_module: XmlEtl
    ]
  end
end
