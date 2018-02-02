defmodule Swappy.Mixfile do
  use Mix.Project

  @version "0.0.2"

  def project do
    [
      app: :swappy,
      version: @version,
      elixir: "~> 1.2",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      description: "Fast, customizable anagram generator",
      package: package(),
      docs: [
        extras: ["README.md"],
        main: "readme",
        source_ref: "v#{@version}",
        source_url: "https://github.com/nathanl/swappy"
      ],
      deps: deps()
    ]
  end

  def package do
    [
      maintainers: ["Nathan Long - him@nathanmlong.com"],
      licenses: ["MIT"],
      links: %{"Github" => "https://github.com/nathanl/swappy"}
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [
      applications: [:logger]
    ]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:ex_doc, "~> 0.10", only: :dev},
      {:earmark, ">= 0.0.0", only: :dev}
    ]
  end
end
