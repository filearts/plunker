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
              </body>
            </html>
            """
          filename: "index.html"
        "style.css":
          content: ""
          filename: "style.css"
        "script.js":
          content: ""
          filename: "script.js"
          
        
    constructor: ->
      angular.copy Scratch.defaults, @
      
    
    requestPreview: ->
      dfd = $q.defer()
      
      request = $http.post("#{url.api}/previews", @toPreviewJSON())
      request.then (response) ->
        dfd.resolve(response.data)
      , (error) ->
        dfd.reject(error)
      
      dfd.promise
    
    toPreviewJSON: ->
      json =
        files: {}
      
      angular.forEach @files, (file, filename) ->
        json.files[filename] =
          content: file.content
      
      json
]
