#= require ../vendor/jquery
#= require ../vendor/jquery.ui.custom
#= require ../vendor/jquery.layout
#= require ../vendor/angular

module = angular.module("plunker.layout", [])

module.directive "plunkerLayout", ->
  restrict: "A"
  link: ($scope, el, attrs) ->
    $(el).layout
      defaults:
        spacing_open: 4
        spacing_closed: 8
      center:
        minSize: 100
      south:
        initClosed: true
      east:
        initClosed: false
        size: Math.max(0, ($("body").width() - 160) / 2)
      west:
        initClosed: false
        size: 160
        minSize: 160
        maxSize: 320
      onresize: -> $scope.$broadcast "layout:resize"
