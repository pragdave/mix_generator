defmodule Child do

  @moduledoc File.read!(Path.join([__DIR__, "../README.md"]))
  
  use MixTemplates,
    name:       :child,
    short_desc: "Template for ....",
    source_dir: "../template",
    based_on:   Path.join(__DIR__, "../../project"),
    options:   [
      name_of_child: [ to: :child_name ]
    ]


  def clean_up(assigns) do
    File.rm!(Path.join([assigns.target_subdir, "lib", "#{assigns.project_name}.ex"]))
  end
end


