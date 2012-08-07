#= require ../vendor/jquery
#= require ../vendor/angular

#= require ../services/scratch
#= require ../services/url

#= require ../directives/userpanel
#= require ../directives/layout
#= require ../directives/ace
#= require ../directives/multipanel
#= require ../directives/toolbar
#= require ../directives/statusbar


module = angular.module("plunker.editor", ["plunker.scratch", "plunker.url", "plunker.userpanel", "plunker.layout", "plunker.ace", "plunker.statusbar", "plunker.multipanel", "plunker.toolbar"])

module.config ["$routeProvider", "$locationProvider", ($routeProvider, $locationProvider) ->
  $locationProvider.html5Mode(true).hashPrefix("!")
]

module.controller "editor", ["$scope", "$location", "scratch", "url", ($scope, $location, scratch, url) ->
  $scope.url = url
  
  # Watch for changes in the path and load the appropriate plunk into the scratch
  $scope.$watch (-> $location.path()), (path) ->
    if path is "/" then scratch.reset()
    else
      source = path.slice(1)
      unless scratch.plunk.id is source then scratch.loadFrom source, ->
        # Hack to force a repaint after AngularJS does first rendering
        setTimeout ->
          console.log "Re-render hack"
          el = $(".plnk-sidebar")[0]
          el.style.display = "none"
          el.offsetHeight
          el.style.display = "block"
        , 1
  
  $scope.scratch = scratch
  

]