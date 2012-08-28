modes =
  c_cpp:
    title: "C/C++"
    extensions: ["c", "cpp", "cxx", "h", "hpp"]
  clojure:
    title: "Clojure"
    extensions: ["clj"]
  coffee:
    title: "CoffeeScript"
    extensions: ["coffee"]
  coldfusion:
    title: "ColdFusion"
    extensions: ["cfm"]
  csharp:
    title: "C#"
    extensions: ["cs"]
  css:
    title: "CSS"
    extensions: ["css"]
  groovy:
    title: "Groovy"
    extensions: ["groovy"]
  haxe:
    title: "haXe"
    extensions: ["hx"]
  html:
    title: "HTML"
    extensions: ["html", "htm"]
  java:
    title: "Java"
    extensions: ["java"]
  javascript:
    title: "JavaScript"
    extensions: ["js"]
  json:
    title: "JSON"
    extensions: ["json"]
  latex:
    title: "LaTeX"
    extensions: ["tex"]
  lua:
    title: "Lua"
    extensions: ["lua"]
  markdown:
    title: "Markdown"
    extensions: ["md", "markdown"]
  ocaml:
    title: "OCaml"
    extensions: ["ml", "mli"]
  perl:
    title: "Perl"
    extensions: ["pl", "pm"]
  pgsql:
    title: "pgSQL"
    extensions: ["pgsql", "sql"]
  php:
    title: "PHP"
    extensions: ["php"]
  powershell:
    title: "Powershell"
    extensions: ["ps1"]
  python:
    title: "Python"
    extensions: ["py"]
  scala:
    title: "Scala"
    extensions: ["scala"]
  scss:
    title: "SCSS"
    extensions: ["scss"]
  ruby:
    title: "Ruby"
    extensions: ["rb"]
  sql:
    title: "SQL"
    extensions: ["sql"]
  svg:
    title: "SVG"
    extensions: ["svg"]
  text:
    title: "Text"
    extensions: ["txt"]
  textile:
    title: "Textile"
    extensions: ["textile"]
  xml:
    title: "XML"
    extensions: ["xml"]

# Build the regex's to match the modes
for name, mode of modes
  mode.name = name
  mode.regex =  new RegExp("\\.(" + mode.extensions.join("|") + ")$", "i")
  mode.source = "ace/mode/#{name}"
  
modes.findByFilename = (filename) ->
  for name, mode of modes
    if filename.match(mode.regex) then return mode
  
  modes.text

module = angular.module("plunker.modes", [])

module.service "modes", -> modes