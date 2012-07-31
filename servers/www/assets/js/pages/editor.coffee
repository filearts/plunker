#= require ../vendor/jquery
#= require ../vendor/underscore
#= require ../vendor/angular

#= require ../services/plunks
#= require ../services/importer

#= require ../directives/userpanel
#= require ../directives/layout
#= require ../directives/ace
#= require ../directives/previewer


module = angular.module("plunker.editor", ["plunker.plunks", "plunker.userpanel", "plunker.layout", "plunker.ace", "plunker.previewer", "plunker.importer"])

module.config ["$routeProvider", "$locationProvider", ($routeProvider, $locationProvider) ->
  $locationProvider.html5Mode(true).hashPrefix("!")
]

module.controller "editor", ["$scope", "$location", "$routeParams", "importer", "Plunk", "plunk", "url", ($scope, $location, $routeParams, importer, Plunk, plunk, url) ->
  $scope.url = url
  $scope.plunk = new Plunk
  
  $scope.validFiles = (files) ->
    ret = {}
    ret[filename] = file for filename, file of files when file
    ret
  
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
      
  $scope.$watch "plunk.isOwner()", (isOwner) ->
    if isOwner
      $scope.saveText = "Save"
      $scope.saveTitle = "Save your work as a new Plunk"
      $scope.saveIcon = "icon-save"
    else
      $scope.saveText = "Fork"
      $scope.saveTitle = "Save your work as a fork of the original Plunk"
      $scope.saveIcon = "icon-save"
    
  $scope.save = ->
    old_id = $scope.plunk.id
    $scope.plunk.save (plunk) ->
      $location.path("/#{plunk.id}")
      $location.replace() unless old_id and old_id != plunk.id
    , (error) -> alert("Save error: #{error}")
  
  $scope.destroy = ->
    $scope.plunk.destroy ->
      $location.path("/").replace()
    , (error) -> alert("Delete error: #{error}")
    
  $scope.history = new class
    constructor: ->
      self = @
      self.queue = []#_.values($scope.plunk.files)
      
      $scope.$watch "plunk.files", (files) ->
        files = _.values(files)
        self.queue = _.chain(self.queue).intersection(files).union(files).value()
      , true
      
      # This time watch for changes to the reference only (triggered on reset)
      $scope.$watch "plunk.files", (files) ->
        self.queue = _.values(files)
        self.activateGuess(files)
      
      #@activateGuess()
    
    activateGuess: (files) ->
      @activate(index) if index = files["index.html"]
    
    last: -> @queue[0]
    activate: (file) ->
      @queue.splice(i, 1) if (i = @queue.indexOf(file)) >= 0
      @queue.unshift(file)
  
    $scope.promptFileAdd = (new_filename) ->
      files = $scope.plunk.files
      
      if new_filename ||= prompt("Please enter the name for the new file:")
        for filename, file of files
          if file.filename == new_filename
            alert("A file already exists called: '#{new_filename}'")
            return
        
        files[new_filename] =
          filename: new_filename
          content: ""
    
    $scope.promptFileRemove = (filename) ->
      files = $scope.plunk.files
      
      if files[filename] and confirm("Are you sure that you would like to remove the file '#{filename}?")
        files[filename] = null
    
    $scope.promptFileRename = (filename, new_filename) ->
      files = $scope.plunk.files
      
      if files[filename] and (new_filename ||= prompt("Please enter the name for new name for the file:"))
        for existing_filename, file of files
          if file.filename == new_filename
            alert("A file already exists called: '#{new_filename}'")
            return
      
        files[filename].filename = new_filename

]