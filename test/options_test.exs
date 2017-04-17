defmodule OptionsTest do
  use ExUnit.Case
  alias MixTaskGen.Options
  
  test "names extracted from spec" do
    spec = [ one: []] 
    assert Options.name_of(hd spec) == :one

    spec = [ two: [ to: :second ]]
    assert Options.name_of(hd spec) == :second
  end

  test "defaults copied in" do
    spec = [ one: [ default: 1], two: [], three: [ default: :iii], four: []] 
    options = Options.get_defaults(spec)
    assert Enum.count(options) == 2
    assert options.one   == 1
    assert options.three == :iii
  end

  test "options created from args" do
    args = [ name: "fred", force: true, answer: 42 ]
    specs = [
      name:   [],
      force:  [ to: :please ],
      answer: []
    ]
    options = Options.add_options_from(%{}, args, specs)

    assert Enum.count(options) == 3
    assert options.name   == "fred"
    assert options.please == true
    assert options.answer == 42
  end

  test "unknown option raises an error" do
    args = [ name: "fred", force: true, wibble: false, answer: 42 ]
    specs = [
      name:   [],
      force:  [ to: :please ],
      answer: []
    ]

    error = assert_raise(Mix.Error, fn ->
      Options.add_options_from(%{}, args, specs)
    end)

    assert error.message =~ ~r/wibble/
  end

  test "missing required option raises error" do
    specs = [
      name:   [],
      wibble: [ required: true ],
      answer: []
    ]

    error = assert_raise(Mix.Error, fn ->
      Options.verify_required_options_are_present(%{fred: 123}, specs)
    end)

    assert error.message =~ ~r/wibble/
  end

  test "aliases" do
    specs = [
      age:    [ default: 22, required: true ],
      height: [ same_as: :age ],
      weight: [ same_as: :age ],
      waist:  [ default: 999]
    ]

    specs1 = Options.normalize_aliases(specs)

    assert specs1.age[:default]    == 22
    assert specs1.height[:default] == 22
    assert specs1.weight[:default] == 22
    assert specs1.waist[:default]  == 999

  end
  
  test "api" do

    args = [ name: "fred", age: 33 ]
    specs = [
      name:   [],
      age:    [ default: 22, required: true ],
      height: [ default: 1.5 ]
    ]

    options = Options.from_args(args, specs)
    assert Enum.count(options) == 3
    assert options.name   == "fred"
    assert options.age    == 33
    assert options.height == 1.5
  end
    
end
