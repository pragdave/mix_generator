defmodule MixTaskGen.Options do

  use Private

  
  def from_args(args, option_specs) do
    option_specs
    |> normalize_aliases
    |> get_defaults
    |> add_options_from(args, option_specs)
    |> verify_required_options_are_present(option_specs)
  end


  private do

    #####################
    # normalize_aliases #
    #####################

    defp normalize_aliases(specs) do
      for {name, spec} <- specs, into: %{} do
        if alias_name = spec[:same_as] do
          { name, specs[alias_name] }
        else
          { name, spec }
        end
      end
    end
    
    #####################
    # get_defaults_from #
    #####################
    
    defp get_defaults(option_specs) do
      option_specs
      |> Enum.reduce(%{}, &maybe_add_default/2)
    end

    defp maybe_add_default(spec = {name, details}, options) do
      case Keyword.fetch(details, :default) do
        :error ->
          options
        { :ok, value } ->
          create_option(spec, value, options)
      end
    end

    ####################
    # add_options_from #
    ####################

    defp add_options_from(options, args, option_specs) do
      args
      |> Enum.reduce(options, fn arg, options ->
        option_from(options, arg, option_specs)
      end)
    end

    defp option_from(options, {name, value}, specs) do
      case Keyword.fetch(specs, name) do
        :error ->
          Mix.raise "Unknown option “--#{name}”"
        { :ok, spec } ->
          create_option({name, spec}, value, options)
      end
    end

    defp option_from(options, x, specs) do
      raise inspect [options, x, specs]
    end
                                       
    
    #######################################
    # verify_required_options_are_present #
    #######################################

    defp verify_required_options_are_present(options, specs) do
      for { name, details } <- specs, details[:required] do
          if !options[name] do
            Mix.raise("required parameter “--#{name}” is missing")
          end
      end
      options
    end
    
    ###########
    # Utility #
    ###########
    
    defp create_option(spec, value, options) do
      Map.put(options, name_of(spec), value)
    end

    defp name_of({ name, details }) do
      details[:to] || name
    end
  end
  
end
