#= require ../vendor/angular

module = angular.module "plunker.importer", []

module.controller "ImporterController", ["$scope", "Plunk", ($scope, Plunk) ->
  class ImporterController
    @$inject = ["$scope", "Plunk"]
    
    constructor: ->
      $scope.value = "HELLOOO"
]
