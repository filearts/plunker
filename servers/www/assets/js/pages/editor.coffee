#= require ../../select2/select2

#= require ../vendor/angular-ui

#= require ../services/scratch
#= require ../services/url

#= require ../directives/userpanel
#= require ../directives/layout
#= require ../directives/ace
#= require ../directives/multipanel
#= require ../directives/toolbar
#= require ../directives/statusbar


module = angular.module("plunker.editor", ["ui.directives", "plunker.scratch", "plunker.url", "plunker.userpanel", "plunker.layout", "plunker.ace", "plunker.statusbar", "plunker.multipanel", "plunker.toolbar"])

module.value "ui.config",
  select2:
    tags:["angularjs","angular-ui","jquery","bootstrap","jquery-ui","coffee", "YUI"]
    tokenSeparators: [",", " "]


module.directive "selectList", ->
  restrict: "A"
  require: "ngModel"
  priority: 1
  link: ($scope, element, args, ngModel) ->
    ngModel.$parsers.push (options = []) ->
      tags = []
      tags.push(option.text) for option in options
      tags
  

module.config ["$routeProvider", "$locationProvider", ($routeProvider, $locationProvider) ->
  $locationProvider.html5Mode(true)
]

module.controller "editor", ["$scope", "$location", "scratch", "url", ($scope, $location, scratch, url) ->
  $scope.url = url
  
  repaintSidebar = ->
    # Hack to force a repaint after AngularJS does first rendering
    setTimeout ->
      el = $(".plnk-sidebar")[0]
      el.style.display = "none"
      el.offsetHeight
      el.style.display = "block"
    , 1
  
  # Watch for changes in the path and load the appropriate plunk into the scratch
  $scope.$watch (-> $location.path()), (path) ->
    if path is "/" then scratch.reset()
    else
      source = path.slice(1)
      unless scratch.plunk.id is source then scratch.loadFrom(source).then(repaintSidebar)
  
  $scope.scratch = scratch
  $scope.scratch.reset(_plunker.bootstrap) if _plunker.bootstrap
  
  $scope.isPaneEnabled = (pane) -> !pane.hidden
  
  repaintSidebar()

]