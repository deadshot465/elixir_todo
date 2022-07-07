defmodule TodoCache.MixProject do
  use Mix.Project

  def project do
    [
      app: :todo_cache,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {TodoCache, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:poolboy, "~> 1.5"},
      {:cowboy, "~> 2.9"},
      {:plug, "~> 1.13"},
      {:plug_cowboy, "~> 2.5"}
    ]
  end
end
