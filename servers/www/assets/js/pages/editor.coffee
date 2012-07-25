#= require ../vendor/jquery
#= require ../vendor/underscore
#= require ../vendor/angular

#= require ../services/plunks
#= require ../services/scratch

#= require ../directives/userpanel
#= require ../directives/layout
#= require ../directives/ace
#= require ../directives/previewer


module = angular.module("plunker.editor", ["plunker.scratch", "plunker.plunks", "plunker.userpanel", "plunker.layout", "plunker.ace", "plunker.previewer"])


module.controller "editor", ["$scope", "scratch", "Plunk", ($scope, scratch, Plunk) ->
  $scope.scratch = scratch
  
  $scope.history = new class
    constructor: ->
      self = @
      self.queue = _.values(scratch.files)
      
      $scope.$watch "scratch.files", (files) ->
        filenames = _.values(scratch.files)
        self.queue = _.chain(self.queue).intersection(filenames).union(filenames).value()
      , true
      
      @activate(index) if index = scratch.files["index.html"]
    
    last: -> @queue[0]
    activate: (file) ->
      @queue.splice(i, 1) if (i = @queue.indexOf(file)) >= 0
      @queue.unshift(file)
]