#= require ../vendor/jquery
#= require ../vendor/underscore
#= require ../vendor/angular

#= require ../services/plunks
#= require ../services/scratch
#= require ../services/importer

#= require ../directives/userpanel
#= require ../directives/layout
#= require ../directives/ace
#= require ../directives/previewer


module = angular.module("plunker.editor", ["plunker.scratch", "plunker.plunks", "plunker.userpanel", "plunker.layout", "plunker.ace", "plunker.previewer", "plunker.importer"])

module.config ["$routeProvider", "$locationProvider", ($routeProvider, $locationProvider) ->
  $locationProvider.html5Mode(true).hashPrefix("!")
]


class SourceController
  @$inject = ["$routeParams", "plunk", "importer"]
  constructor: ($routeParams, plunk, importer) ->
    console.log "source", arguments...

module.controller "editor", ["$scope", "$location", "$routeParams", "scratch", "importer", "Plunk", "plunk", "url", ($scope, $location, $routeParams, scratch, importer, Plunk, plunk, url) ->
  $scope.url = url
  $scope.scratch = scratch 
  $scope.plunk = new Plunk
  
  loadPlunk = (source) ->
    $scope.loading = true
    importer.import(source.slice(1)).then (json) ->
      $scope.plunk = new Plunk(json)
      $scope.loading = false
    , (error) ->
      alert("Failed to load plunk: #{error}")
      $location.path("/")
      $scope.loading = false
  
  $scope.$watch (-> $location.path()), (path) ->
    if path is "/" then $scope.plunk = new Plunk
    else
      loadPlunk(path) unless path is "/" or path.slice(1) is $scope.plunk.id
  
  # Watch for changes to the plunk *reference*
  $scope.$watch "plunk.files", (files) ->
    scratch.files = angular.copy(files)
    
  # Watch for changes tot he plunk id and update accordingly
  $scope.$watch "plunk.id", (id, old_id) ->
    $location.path("/#{id}").replace() if id and not old_id
  
  $scope.save = ->
    $scope.plunk.save(scratch)
    
  $scope.history = new class
    constructor: ->
      self = @
      self.queue = _.values(scratch.files)
      
      $scope.$watch "scratch.files", (files) ->
        filenames = _.values(scratch.files)
        self.queue = _.chain(self.queue).intersection(filenames).union(filenames).value()
      , true
      
      # This time watch for changes to the reference only (triggered on reset)
      $scope.$watch "scratch.files", (files) ->
        self.activateGuess()
      
      @activateGuess()
    
    activateGuess: ->
      @activate(index) if index = scratch.files["index.html"]
    
    last: -> @queue[0]
    activate: (file) ->
      @queue.splice(i, 1) if (i = @queue.indexOf(file)) >= 0
      @queue.unshift(file)
]