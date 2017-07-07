Code.require_file "./test_helper.exs", __DIR__

defmodule MixGeneratorTest do
  use ExUnit.Case

  @template        Path.join(__DIR__, "../test_templates/project")
  @child_template  Path.join(__DIR__, "../test_templates/child")
  @project_name    "cecil"
  @project_name_camel_case "Cecil"

  test "basic project can be created" do
    in_tmp(%{
          setup: fn ->
             Mix.Tasks.Gen.run([ @template, @project_name ])
           end,
          test: fn ->
            ~w{ .gitignore
                README.md
                mix.exs
                config/config.exs
                lib/#{@project_name}.ex
                test/#{@project_name}_test.exs
                test/test_helper.exs
              }
              |> Enum.each(&assert_file/1)

            assert_file("mix.exs", ~r/@name\s+:#{@project_name}/)
            assert_file("lib/#{@project_name}.ex", ~r/defmodule #{@project_name_camel_case}/)
          end})
  end

  test "basic project can be created when name is capitalized" do
    in_tmp(%{
          setup: fn ->
             Mix.Tasks.Gen.run([ @template, String.capitalize(@project_name) ])
           end,
          test: fn ->
            ~w{ .gitignore
                README.md
                mix.exs
                config/config.exs
                lib/#{@project_name}.ex
                test/#{@project_name}_test.exs
                test/test_helper.exs
              }
              |> Enum.each(&assert_file/1)

            assert_file("mix.exs", ~r/@name\s+:#{@project_name}/)
            assert_file("lib/#{@project_name}.ex", ~r/defmodule #{@project_name_camel_case}/)
          end})
  end

  test "project with --sup can be created" do
    in_tmp(%{
          setup: fn ->
             Mix.Tasks.Gen.run([ @template, @project_name, "--sup" ])
           end,
          test: fn ->
            ~w{ .gitignore
                README.md
                mix.exs
                config/config.exs
                lib/#{@project_name}.ex
                lib/#{@project_name}/application.ex
                test/#{@project_name}_test.exs
                test/test_helper.exs
              }
              |> Enum.each(&assert_file/1)

            %{
              "mix.exs" =>
                ~r/@name\s+:#{@project_name}/,
              "lib/#{@project_name}.ex" =>
                ~r/defmodule #{@project_name_camel_case}/,
              "lib/#{@project_name}/application.ex" =>
                ~r/defmodule #{@project_name_camel_case}.Application/,
              "lib/#{@project_name}/application.ex" =>
                ~r/#{@project_name_camel_case}.Supervisor/
            }
            |>
            Enum.each(fn {file, content} ->
              assert_file(file, content)
            end)
         end})
  end

  # the child project is like project, but adds a file lib/child.ex, and removes
  # lib/#{project_name}.ex

  test "template based on another can be created" do
    in_tmp(%{
          setup: fn ->
             Mix.Tasks.Gen.run([ @child_template, @project_name,
                                 "--name_of_child", "cedric" ])
           end,
          test: fn ->

            ~w{ .gitignore
                README.md
                mix.exs
                config/config.exs
                lib/child.ex
                test/#{@project_name}_test.exs
                test/test_helper.exs
              }
              |> Enum.each(&assert_file/1)

            %{
              "mix.exs" =>
                ~r/@name\s+:#{@project_name}/,
              "lib/child.ex" =>
                ~r/Child is called cedric/,
            }
            |>
            Enum.each(fn {file, content} ->
              assert_file(file, content)
            end)

            assert !File.exists?("lib/#{@project_name}.ex")
         end})
  end

  ############################################################

  # stolen from mix/test/tasks/new

  defp assert_file(file) do
    assert File.regular?(file), "Expected #{file} to exist, but does not"
  end

  defp assert_file(file, matcher) when is_function(matcher, 1)  do
    assert_file(file)
    matcher.(File.read!(file))
  end

  defp assert_file(file, match) do
    assert_file file, &(assert &1 =~ match)
  end

  def in_tmp(%{setup: setup, test: tests}) do
    System.tmp_dir!
    |> File.cd!(fn ->
         File.rm_rf!(@project_name)
         setup.()
         assert File.dir?(@project_name)
         File.cd!(@project_name, fn ->
           tests.()
         end)
         File.rm_rf!(@project_name)
    end)
  end

end
