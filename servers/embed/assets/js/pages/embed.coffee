#= require ../vendor/jquery
#= require ../vendor/angular
#= require ../vendor/angular-sanitize
#= require ../vendor/showdown
#= require ../vendor/prettify

#= require ../../bootstrap/js/bootstrap-all

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
  $scope.plunk = new Plunk
  $scope.loading = "Initializing..."
  $scope.tab = $location.search().t or "run"
  
  $scope.selectFile = (file) -> $scope.currentFile = file
  $scope.activateFile = (file) ->
    $scope.selectFile(file)
    $scope.tab = "code"
    
    $timeout -> $('.navbar .dropdown.open .dropdown-toggle').dropdown('toggle')
    
  $scope.$watch "currentFile", (tab) ->
    $timeout -> prettyPrint() 
  
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
  
  $scope.$watch ( -> $location.path().slice(1) ), (id) ->
    $scope.loading = "Loading..."
    
    $scope.plunk.reset()
    $scope.plunk.id = id
    
    $scope.plunk.fetch (plunk) ->
      for filename, file of plunk.files
        first = file
        break
      
      $scope.selectFile plunk.files[$location.search().f or "index.html"] or first
      
      document.title = "Plunker - #{plunk.description}"
      
      if $scope.tab == "run" then $scope.refreshPreview() 
      else $scope.loading = ""
      
    , (err) ->
      $scope.loading = err.toString()
]