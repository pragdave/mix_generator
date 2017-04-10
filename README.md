# Mix Generator—An alternative project generator for Mix

Generate skeleton directories and files for new Elixir projects of
various styles. This is the same idea as `mix new`, `mix nerves.new`, 
`mix phoenix.new`, but all under one roof. It is also open ended—anyone
can write a new template, and anyone can publish a template for others 
to use.

### Install

    $ mix archive.install mix_templates
    $ mix archive.install mix_generator
    
Then you can install templates using:

    $ mix template.install «template-name»
    
How do you find templates?

    $ mix template.hex
    
    
### Use


* `$ mix gen --help | -h`

  Show this information

* `$ mix gen --list | -l`

  Show locally installed templates. Same as `mix template list`

* `$ mix gen «template-name» --help`

  See specific information for «template-name»

* `$ mix gen «template-name» «project-name»  [ options ... ]`

  Generate a new project called «project-name» using the
  template «template-name». This will be created in
  a directory with the same name as the project.  By default, this
  directory will be created under the current directory. This can be
  overridden with the `--into` option, which specifies a new containing
  directory.

###  Options:

As well as `--into «dir»` each individual template may define its own set
of options. For example, the `project` template will have its own options 
for creating supervised apps and so on.

Use `mix gen «template-name» --help` to see a list of these options.

### Examples

    $ mix gen project simple_app

    $ mix gen project super_app --supervised --into ~/projects/

