defmodule Exmor.Mixfile do
  use Mix.Project

  def project do
    [app: :exmor,
     version: "0.0.1",
     elixir: "~> 1.0",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications:  [
                      :logger,
                      :silverb,
                      :tinca,
                      :hashex,
                      :jazz,
                      :logex,
                      :exutils
                    ],
     mod: {Exmor, []}]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    [
      {:silverb, github: "timCF/silverb"},
      {:tinca, github: "timCF/tinca"},
      {:hashex, github: "timCF/hashex"},
      {:jazz, github: "meh/jazz"},
      {:logex, github: "timCF/logex"},
      {:exutils, github: "timCF/exutils"}
    ]
  end
end
