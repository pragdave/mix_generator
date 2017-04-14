defmodule <%= @project_name_camel_case %>.Mixfile do
  use Mix.Project

  @name    :<%= @project_name %>
  @version "0.1.0"

  @deps [
    # { :earmark, ">0.1.5" },                      
    # { :ex_doc,  "1.2.3", only: [ :dev, :test ] }
    # { :my_app:  path: "../my_app" },
  ]
  
  # ------------------------------------------------------------
  
  def project do
    in_production = Mix.env == :prod
    [
      app:     @name,
      version: @version,
      elixir:  ">= <%= @elixir_version %>",
<%= if @in_umbrella? do %>
      build_path:      "../../_build",
      config_path:     "../../config/config.exs",
      deps_path:       "../../deps",
      lockfile:        "../../mix.lock",
      start_permanent: in_production,
<% else %>
      deps:    @deps,
      build_embedded:  in_production,
<% end %>
    ]
  end

  def application do
    [
<%= if @is_supervisor? do %>
      mod: { <%= @project_name_camel_case %>.Application, [] },         # Entry point module and parameters
<% end %>
      extra_applications: [         # built-in apps that need starting    
        :logger
      ], 
    ]
  end

end
