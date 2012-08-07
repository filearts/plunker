#= require ../vendor/jquery
#= require ../vendor/angular

#= require ../services/plunks

#= require ../directives/userpanel
#= require ../directives/card

module = angular.module("plunker.landing", ["plunker.userpanel", "plunker.plunks", "plunker.card"])

module.config ["$routeProvider", "$locationProvider", ($routeProvider, $locationProvider) ->
  
  #$locationProvider.html5Mode(true)
]

module.controller "GalleryController", ["$scope", "$location", "Plunk", ($scope, $location, Plunk) ->
  $scope.$watch (-> $location.search()), (search) ->
    page = parseInt(search.p, 10) or 1
    size = parseInt(search.pp, 10) or 8
    
    $scope.plunks = Plunk.query
      page: page
      size: size
  
  $scope.pageTo = (url) ->
    matches = url.match(/\?(p=\d+&pp=\d+)/i)
    
    $location.search(matches[1])
    
    $scope.plunks = Plunk.query(url)
]

module.controller "ImporterController", ["$scope", "Plunk", ($scope, Plunk) ->
  class ImporterController
    @$inject = ["$scope", "Plunk"]
    
    constructor: ->
      $scope.value = "HELLOOO"
]
