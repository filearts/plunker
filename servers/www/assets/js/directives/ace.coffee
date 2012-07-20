module = angular.module("plunker.ace", [])

module.directive "plunkerAce", ->
  restrict: "A"
  link: ($scope, el, attrs) ->
    $scope.ace = ace.edit(el[0])
    $scope.$on "layout:resize", ->
      $scope.ace.resize()