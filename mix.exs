defmodule ArkeAuth.MixProject do
  use Mix.Project

  def project do
    [
      app: :arke_auth,
      version: "0.1.4",
      build_path: "./_build",
      config_path: "./config/config.exs",
      deps_path: "./deps",
      lockfile: "./mix.lock",
      elixir: "~> 1.13",
      dialyzer: [plt_add_apps: ~w[eex]a],
      description: description(),
      package: package(),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      elixirc_paths: elixirc_paths(Mix.env()),
      elixirc_options: [warnings_as_errors: false],
      test_coverage: [tool: ExCoveralls]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {ArkeAuth.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    List.flatten([
      {:bcrypt_elixir, "~> 1.0"},
      {:typed_struct, "~> 0.2.1"},
      {:comeonin, "~> 4.0"},
      {:guardian, "~> 2.2.3"},
      {:ex_doc, "~> 0.28", only: :dev, runtime: false},
      {:excoveralls, "~> 0.10", only: :test},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:arke, "~> 0.1.5"}
    ])
  end

  defp aliases do
    [
      test: [
        "test"
      ],
      "test.ci": [
        "test"
      ]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp description() do
    "Arke Auth"
  end

  defp package() do
    [
      # This option is only needed when you don't want to use the OTP application name
      name: "arke_auth",
      # These are the default files included in the package
      licenses: ["Apache-2.0"],
      links: %{
        "Website" => "https://arkehub.com",
        "Github" => "https://github.com/arkemishub/arke-auth"
      }
    ]
  end
end
