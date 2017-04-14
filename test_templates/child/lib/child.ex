defmodule Child do

  @moduledoc File.read!(Path.join([__DIR__, "../README.md"]))
  
  use MixTemplates,
    name:       :child,
    short_desc: "Template for ....",
    source_dir: "../template",
    based_on:   Path.join(__DIR__, "../../project")

  def populate_assigns(assigns, options) do
    Map.put(assigns, :child_name, options[:name_of_child])
  end

  def clean_up(assigns) do
    File.rm!(Path.join([assigns.target_subdir, "lib", "#{assigns.project_name}.ex"]))
  end
end


