#= require ../vendor/jquery
#= require ../vendor/angular

#= require ../services/plunks

#= require ../directives/userpanel
#= require ../directives/card

module = angular.module("plunker.landing", ["plunker.userpanel", "plunker.plunks", "plunker.card"])

module.controller "LandingController", ["$rootScope", ($rootScope) ->

]

module.config ["$routeProvider", "$locationProvider", ($routeProvider, $locationProvider) ->
  
  $locationProvider.html5Mode(true)
  $routeProvider.when "/", templateUrl: "/partials/home", controller: "HomeController"
  $routeProvider.when "/discuss", templateUrl: "/partials/discuss", controller: "DiscussController"
  $routeProvider.when "/:plunk/:filename", templateUrl: "/partials/preview", controller: "PreviewController"
  $routeProvider.when "/:plunk", templateUrl: "/partials/preview", controller: "PreviewController"
  $routeProvider.otherwise redirectTo: "/"
]

module.controller "HomeController", [ "$scope", ($scope) ->
  $scope.$parent.section = "home"

]

module.controller "PreviewController", [ "$scope", "$routeParams", "$location", "$timeout", "Plunk", ($scope, $routeParams, $location, $timeout, Plunk) ->
  $scope.state = "loading"
  $scope.plunk = new Plunk(id: $routeParams.plunk)
  $scope.resizePreview = ->
    $footer = $("#container footer")
    targetHeight = $(window).height() - 50 - 38 - $footer.outerHeight() - 2
    minHeight = $("#plunk-info").outerHeight()
    
    $("iframe.plnk-preview").height(Math.max(minHeight, targetHeight))

  $(window).resize($scope.resizePreview);

  $scope.plunk.fetch ->
    $scope.state = "ready"
    $timeout -> $scope.resizePreview()
  , (err) ->
    $location.path("/")
    
  $scope.$parent.section = "browse"
  
]
module.controller "UserDetailController", [ "$scope", "$routeParams", "$location", "$timeout", "Plunk", ($scope, $routeParams, $location, $timeout, Plunk) ->
  $scope.state = "loading"
  $scope.plunk = new Plunk(id: $routeParams.plunk)
  $scope.resizePreview = ->
    $footer = $("#container footer")
    targetHeight = $(window).height() - 50 - 38 - $footer.outerHeight() - 2
    minHeight = $("#plunk-info").outerHeight()
    
    $("iframe.plnk-preview").height(Math.max(minHeight, targetHeight))

  $(window).resize($scope.resizePreview);

  $scope.plunk.fetch ->
    $scope.state = "ready"
    $timeout -> $scope.resizePreview()
  , (err) ->
    $location.path("/")
    
  $scope.$parent.section = "browse"
  
]
module.controller "DiscussController", [ "$scope", ($scope) ->
  $iframe = $("#forum_embed")
  $footer = $("#container footer")

  $scope.$parent.section = "discuss"
  
  $scope.resizeDiscussion = ->
    minHeight = 400
    $iframe.height(Math.max(minHeight, $(window).height() - 50 - 38 - $footer.outerHeight()))
  
  $(window).resize($scope.resizeDiscussion)
  
  $scope.resizeDiscussion()

  $iframe.attr("src", 'https://groups.google.com/forum/embed/?place=forum/plunker&showsearch=true&showpopout=true&hideforumtitle=true&showtabs=false&parenturl=' + encodeURIComponent(window.location.href));

]

module.controller "GalleryController", ["$scope", "$location", "Plunk", ($scope, $location, Plunk) ->
  $scope.$watch (-> $location.search()), (search) ->
    page = parseInt(search.p, 10) or 1
    size = parseInt(search.pp, 10) or 8
    
    $scope.plunks = Plunk.query
      page: page
      size: size
  
  $scope.pageTo = (url) ->
    matches = url.match(/\?p=(\d+)&pp=(\d+)/i)
    
    search = $location.search()
    search.p = matches[1] or 1
    search.pp = matches[2] or 8
    
    $location.search(search)
]

module.controller "ImporterController", ["$scope", "Plunk", ($scope, Plunk) ->
  class ImporterController
    @$inject = ["$scope", "Plunk"]
    
    constructor: ->
      $scope.value = "HELLOOO"
]
