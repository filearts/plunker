#= require ../vendor/showdown
#= require ../vendor/prettify
#= require ../vendor/overthrow

#= require ../services/importer
#= require ../services/url


module = angular.module("plunker.embed", ["ngSanitize", "plunker.importer", "plunker.url"])


module.config ["$routeProvider", "$locationProvider", ($routeProvider, $locationProvider) ->
  $locationProvider.html5Mode(true)
]

module.filter "markdown", [ () ->
  converter = new Showdown.converter()
  (value) -> if value then converter.makeHtml(value) else ""
]

module.controller "embed", ["$scope", "$location", "$http", "$timeout", "importer", "url", "Plunk", ($scope, $location, $http, $timeout, importer, url, Plunk) ->
  $scope.url = url
  $scope.plunk = new Plunk(_plunker.plunk or {})
  $scope.loading = "Initializing..."
  $scope.tab = $location.search().t or "run"
  
  $scope.selectFile = (file) -> $scope.currentFile = file
  $scope.activateFile = (file) ->
    $scope.selectFile(file)
    $scope.tab = "code"
    
    $timeout -> $('.navbar .dropdown.open .dropdown-toggle').dropdown('toggle')
    
  $scope.$watch "currentFile", (tab) ->
    $timeout -> prettyPrint()
    
  $scope.launchEditor = (e) ->
    plunk = $scope.plunk
    
    hiddenInput = (name, value) ->
      $("""<input type="hidden" />""").attr("name", name).val(value)
    
    $form = $("""<form action="#{url.www}/edit/" method="post" target="_blank"></form>""")
    
    $form.append hiddenInput "description", plunk.description or ""
    $form.append hiddenInput "tags[]", tag for tag in plunk.tags if plunk.tags
    $form.append hiddenInput "files[#{filename}]", file.content for filename, file of plunk.files if plunk.files
    
    $form.submit()
    
    e.preventDefault()
    e.stopPropagation()
  
  $scope.refreshPreview = ->
    $scope.tab = "run"
    $scope.loading = "Refreshing..."
    $timeout ->
      if iframe = $("#run>iframe")[0]
      
        json = { files: {} }
        
        for filename, file of $scope.plunk.files
          json.files[file.filename] =
            content: file.content
        
        request = $http.post(url.run, json)
        
        request.then (response) ->
          iframe.contentWindow.location.replace(response.data.run_url)
          $scope.loading = ""
        , (err) ->
          $scope.loading = err.toString()
          
  $scope.attachPlunk = (plunk) ->
    for filename, file of plunk.files
      first = file
      break
        
    $scope.selectFile plunk.files[$location.search().f or "index.html"] or first
    
    document.title = "Plunker - #{plunk.description}"
    
    if $scope.tab == "run" then $scope.refreshPreview() 
    else $scope.loading = ""
    
  
  $scope.$watch ( -> $location.path().slice(1) ), (id) ->
    if id and id isnt $scope.plunk.id
      $scope.loading = "Loading..."
      
      $scope.plunk.reset()
      $scope.plunk.id = id
      
      $scope.plunk.fetch (plunk) ->
        $scope.attachPlunk(plunk)
      , (err) ->
        $scope.loading = err.toString()
    else
      $scope.attachPlunk($scope.plunk)
      
]