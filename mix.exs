defmodule MixGenerator.Mixfile do
  use Mix.Project

  @name    :mix_generator
  @version "0.1.9"

  @mix_templates (if System.get_env("GEN_DEV") do
    { :mix_templates, path: "../mix_templates" }
  else
    { :mix_templates, ">= 0.1.10" }
  end)

  @deps [
    @mix_templates,
    { :private,       ">= 0.0.0" },
    { :ex_doc,        ">= 0.0.0", only: :dev },
  ]

  @description """
  This application adds a `gen` task to mix, which generates project trees.

  Unlike `mix new`, it can be fully customized. You can create private variants
  for your own use, and publish public ones that can be shared.
  """

  ############################################################

  def project do
    in_production = Mix.env == :prod
    [
      app:     @name,
      version: @version,
      elixir:  ">= 1.4.0",
      deps:    @deps,
      build_embedded:  in_production,
      start_permanent: in_production,
      package:         package(),
      description:     @description,
    ]
  end

  defp package do
    [
      files: [
        "lib", "mix.exs", "README.md",
      ],
      maintainers: [
        "Dave Thomas <dave@pragdave.me>",
      ],
      licenses: [
        "Apache 2 (see the file LICENSE.md for details)"
      ],
      links: %{
        "GitHub" => "https://github.com/pragdave/mix_generator",
      }
    ]
  end

end
