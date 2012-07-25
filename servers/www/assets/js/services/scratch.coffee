#= require ../vendor/angular

module = angular.module("plunker.scratch", ["plunker.url"])

module.factory "scratch", ["$http", "$q", "url", ($http, $q, url) ->
  new class Scratch
    @defaults:
      description: "Untitled"
      files:
        "index.html":
          content: """
            <!doctype html>
            <html>
              <head>
                <link rel="stylesheet" href="style.css" />
                <script src="script.js"></script>
              </head>
              <body>
                <h1>Basic Plunk</h1>
              </body>
            </html>
            """
          filename: "index.html"
        "style.css":
          content: """
            /* CSS goes here */
            h1 {
              color: blue;
            }
          """
          filename: "style.css"
        "script.js":
          content: """
            // Javascript goes here
          """
          filename: "script.js"
          
        
    constructor: ->
      angular.copy Scratch.defaults, @
    
    promptFileAdd: (new_filename) ->
      if new_filename ||= prompt("Please enter the name for the new file:")
        for filename, file of @files
          if file.filename == new_filename
            alert("A file already exists called: '#{new_filename}'")
            return
        
        @files[new_filename] =
          filename: new_filename
          content: ""
    
    promptFileRemove: (filename) ->
      if @files[filename] and confirm("Are you sure that you would like to remove the file '#{filename}?")
        delete @files[filename]
    
    promptFileRename: (filename, new_filename) ->
      if @files[filename] and (new_filename ||= prompt("Please enter the name for new name for the file:"))
        for filename, file of @files
          if file.filename == new_filename
            alert("A file already exists called: '#{new_filename}'")
            return
      
        @files[filename].filename = new_filename
      
]