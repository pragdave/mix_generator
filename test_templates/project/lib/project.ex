defmodule Mix.Gen.Template.Project do

  @moduledoc File.read!(Path.join([__DIR__, "../README.md"]))
  
  use MixTemplates,
    name:       :project,
    short_desc: "Simple template for projects (with optional app and supervision)",
    source_dir: "../template"

  
  def populate_assigns(assigns, options) do
    assigns = add_defaults_to(assigns)
    options |> Enum.reduce(assigns, &handle_option/2)
  end

  defp add_defaults_to(assigns) do
    assigns
    |> Map.merge(%{ is_supervisor?: false })
  end
  
  defp handle_option({ :app, val }, assigns) do
    %{ assigns | project_name: val }
  end
  
  defp handle_option({ :application, val }, assigns) do
    handle_option({ :app, val }, assigns)
  end

  
  defp handle_option({ :module, val }, assigns) do
    %{ assigns | project_name_camel_case: val }
  end

  
  defp handle_option({ :supervisor, val }, assigns) do
    assigns |> Map.put(:is_supervisor?, val)
  end
  
  defp handle_option({ :sup, val }, assigns) do
    handle_option({ :supervisor, val }, assigns)
  end

  
  defp handle_option({ :umbrella, _ }, _assigns) do
    Mix.shell.info([ "\nPlease use ",
                     :green, "mix gen umbrella.",
                     :reset, "to create an umbrella project\n"])
    Process.exit(self(), :normal)
  end

  defp handle_option({ :into, _ }, assigns), do: assigns

  defp handle_option(_, assigns), do: assigns

  # defp handle_option({ opt, val }, _) do
  #   Mix.shell.error([ :red, "\nError: ",
  #                     :reset, "unknown option ",
  #                     :yellow, "--#{opt} #{inspect val}\n"])
  #   Process.exit(self(), :normal)
  # end
  
  
  
end
