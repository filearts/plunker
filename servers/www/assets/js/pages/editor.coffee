#= require ../vendor/jquery
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
  
  window.scratch = scratch
  
  $scope.setActive = (active) ->
    $scope.active = active
  
  $scope.guessActive = ->
    $scope.active = scratch.files["index.html"]
  $scope.guessActive()
]