defmodule Mix.Gen.Template.Project do

  @moduledoc File.read!(Path.join([__DIR__, "../README.md"]))
  
  use MixTemplates,
    name:       :project,
    short_desc: "Simple template for projects (with optional app and supervision)",
    source_dir: "../template",
    options: [
      sup: [ to: :is_supervisor?, default: false ],
      app: [ ],
      ]

  
  
end
