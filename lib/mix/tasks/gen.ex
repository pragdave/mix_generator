defmodule Mix.Tasks.Gen do

  @moduledoc File.read!(Path.join([__DIR__, "../../../README.md"]))
  
  use Private
  
  use Mix.Task

  alias MixTaskGen.Assigns
  alias MixTemplates.Cache

  @default_options %{
    into: ".",
  }
  
  def run(args) do
    case parse_command(args) do
      :help ->
        usage()
        
      :list ->
        list_local_templates()
        
      { :project, project, name, args } ->
        generate_project(project, name, args)

      { :error, reason } ->
        error(reason)
    end
      
    # # 
    # |> check_valid()
    # # { options, names, assigns }
    # |> populate_assigns_from_context(args)
    # # %{ assigns }
    # |> IO.inspect
    # |> create_output
  end

  private do

    #####################
    # Parameter parsing #
    #####################
    
    def parse_command(["--help"]),  do: :help
    def parse_command(["help"]),    do: :help
    def parse_command(["-h"]),      do: :help
    
    def parse_command(["--list"]),  do: :list
    def parse_command(["-l"]),      do: :list

    def parse_command([option = "-" <> _ | _rest]) do
      { :error, "unknown or misplaced option “#{option}”" }
    end 

    def parse_command([_template_name]) do
      { :error, "missing name of project" }
    end 

    def parse_command([_template_name, "-" <> _ | _rest]) do
      { :error, "missing name of project" }
    end 

    def parse_command([ project, name | rest ]) do
      { :project, project, name, rest }
    end

    def parse_command(other) do
      error("Unknown command: mix gen #{Enum.join(other, " ")}")
    end

    def options_from_args(args) do
      { switches, extra } =
        case OptionParser.parse(args, []) do
          { switches, [], extra } ->
            { switches, extra }
          { _switches, other, _extra } ->
            error("unknown option “#{Enum.join(other, " ")}”")
        end
      
      (extra ++ switches)
      |> Enum.map(&make_params_with_no_arg_true/1)
      |> Enum.into(@default_options)
    end
    
    defp make_params_with_no_arg_true({param, nil}) do
      make_params_with_no_arg_true({param, true})
    end
    defp make_params_with_no_arg_true({"--" <> param, value}) do
      { String.to_atom(param), value }
    end
    defp make_params_with_no_arg_true(other), do: other
    

    ########################
    # mix gen project name #
    ########################
    
    def generate_project(project, name, args) do
      options = options_from_args(args)
      assigns = global_assigns(options, project, name)
      create_output(assigns)
    end
    
    defp global_assigns(options, template_name, project_name) do
      template_module = find_template(template_name)
      %{
        host_os:                 Assigns.os_type(),
        now:                     Assigns.date_time_values(),
        original_args:           options,
        
        project_name:            project_name,
        project_name_camel_case: Macro.camelize(project_name),
        target_dir:              options.into,
        
        template_module:         template_module,
        template_name:           template_name,
      }
      |> template_module.populate_assigns(options)
    end

    
    defp find_template(name = <<".", _ :: binary>>) do
      find_template_file(name)
    end
    
    defp find_template(name = <<"/", _ :: binary>>) do
      find_template_file(name)
    end
    
    defp find_template(template_name) do
      case Cache.find(template_name) do
        nil ->
          error("Cannot find a template called “#{template_name}”")
          list_local_templates("\nHere are the available templates:")
          exit(:normal)
        module ->
          module
      end
    end
    
    defp find_template_file(file_name) do
      [{ module, _code }|_] =  Code.load_file(file_name)
      find_template(module.name())
    end
    
    defp create_output(assigns) do
      case MixTemplates.generate(assigns.template_module, assigns) do
        { :error, reason } ->
          Mix.shell.info([ :red, "Error: ", :reset, reason ])
        :ok ->
          Mix.shell.info([ :green, "Successfully generated ",
                           :reset, assigns.project_name,
                           :green, " in ",
                           :reset, assigns.target_dir])
      end
          
    end


    ###########
    # Utility #
    ###########

    defp error(message, extras \\ nil)
    defp error(message, extras) when is_list(extras) do
      error(message, extras |> Enum.map(&inspect/1) |> Enum.join(", "))
    end
    defp error(message, nil) do
      Mix.shell.info([ :red, "ERROR: ", :reset, message ])
    end
    defp error(message, extras) do
      Mix.shell.info([ :red, message, :reset, extras ])
    end

    defp usage() do
      IO.puts "USAGE:"
      list_local_templates()
      exit(:normal)
    end

    defp list_local_templates(title) do
      IO.puts("\n#{title}\n")
      list_local_templates()
    end
    
    defp list_local_templates() do
      Mix.Task.run("template", [])
    end
  end

end
