<%
#   ------------------------------------------------------------
    MixTemplates.ignore_file_and_directory_unless @is_supervisor?
#   ------------------------------------------------------------
%>
defmodule <%= @project_name_camel_case %>.Application do

  @moduledoc false

  use Application   # See http://elixir-lang.org/docs/stable/elixir/Application.html

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # worker(One.Worker, [arg1, arg2, arg3]),
    ]

    opts = [
      strategy: :one_for_one,
      name:     <%= @project_name_camel_case %>.Supervisor
    ]
    
    Supervisor.start_link(children, opts)
  end
end
