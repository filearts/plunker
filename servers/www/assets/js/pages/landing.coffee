#= require ../../bootstrap/js/bootstrap-all

#= require ../services/plunks
#= require ../services/url
#= require ../services/whitelist

#= require ../directives/userpanel
#= require ../directives/card

module = angular.module("plunker.landing", ["ngResource", "plunker.userpanel", "plunker.plunks", "plunker.card", "plunker.whitelist", "plunker.url"])

module.controller "LandingController", ["$rootScope", ($rootScope) ->

]

module.config ["$routeProvider", "$locationProvider", ($routeProvider, $locationProvider) ->
  
  $locationProvider.html5Mode(true)
  $routeProvider.when "/", templateUrl: "/partials/home", controller: "HomeController"
  $routeProvider.when "/plunks/:ranking", templateUrl: "/partials/home", controller: "HomeController"
  $routeProvider.when "/discuss", templateUrl: "/partials/discuss", controller: "DiscussController"
  $routeProvider.when "/users/:username", templateUrl: "/partials/user", controller: "UserController"
  $routeProvider.when "/users/:username/:ranking", templateUrl: "/partials/user", controller: "UserController"
  $routeProvider.when "/tags/:tagname", templateUrl: "/partials/tag", controller: "TagController"
  $routeProvider.when "/tags", templateUrl: "/partials/tags", controller: "TagsController"
  $routeProvider.when "/users", templateUrl: "/partials/users", controller: "UsersController"  
  $routeProvider.when "/:plunk/:filename", templateUrl: "/partials/preview", controller: "PreviewController"
  $routeProvider.when "/:plunk", templateUrl: "/partials/preview", controller: "PreviewController"
  $routeProvider.otherwise redirectTo: "/"
]

module.run ["whitelist", (whitelist) ->
  # Prevent AngularJS from handling /edit/ urls
  whitelist.push /^\/edit\//
]

module.controller "HomeController", [ "$scope", "$routeParams", "$location", ($scope, $routeParams, $location) ->
  $scope.$parent.section = "plunks"
  
  $scope.filters = []
  
  $scope.filters.push
    name: "trending"
    title: "Trending"
    path: "/plunks/trending"
  
  $scope.filters.push
    name: "popular"
    title: "Popular"
    path: "/plunks/popular"
  
  $scope.filters.push
    name: "recent"
    title: "Recent"
    path: "/plunks/recent"
    
  ranking = $routeParams.ranking or "trending"
  
  for filter in $scope.filters
    if filter.name == ranking
      $scope.ranking = filter
      break
  
  unless $scope.ranking then $location.path("/")
]

module.controller "UserController", [ "$scope", "$resource", "$routeParams", "url", ($scope, $resource, $routeParams, url) ->
  $scope.$parent.section = "users"

  User = $resource("#{url.api}/users/:username", username: "@login")
  
  $scope.username = $routeParams.username
  $scope.user = User.get(username: $routeParams.username)

  $scope.filters = []
  
  $scope.filters.push
    name: "recent"
    title: "Recent"
    path: "/users/#{$scope.username}"
  
  $scope.filters.push
    name: "thumbed"
    title: "Thumbed"
    path: "/users/#{$scope.username}/thumbed"
    
  ranking = $routeParams.ranking or "recent"
  
  for filter in $scope.filters
    if filter.name == ranking
      $scope.ranking = filter
      break
  
  unless $scope.ranking then $location.path("/")
]


module.controller "UserPlunksController", [ "$scope", "$routeParams", "$location","Plunk", "url", ($scope, $routeParams, $location, Plunk, url) ->
  $scope.$watch (-> $location.search()), (search) ->
    page = parseInt(search.p, 10) or 1
    size = parseInt(search.pp, 10) or 8
    
    ranking = $scope.ranking.name or $routeParams.ranking or "recent"
    
    suffixes =
      recent: "/plunks"
      thumbed: "/thumbed"
    
    $scope.plunks = Plunk.query
      url: "#{url.api}/users/#{$routeParams.username}#{suffixes[ranking]}"
      page: page
      size: size
      
  $scope.pageTo = (url) ->
    matches = url.match(/\?p=(\d+)&pp=(\d+)/i)
    
    search = $location.search()
    search.p = matches[1] or 1
    search.pp = matches[2] or 8
    
    $location.search(search)
]
module.controller "TagController", [ "$scope", "$routeParams", "$location","Plunk", "url", ($scope, $routeParams, $location, Plunk, url) ->
  $scope.$parent.section = "tags"
  
  $scope.tagname = $routeParams.tagname
  
  $scope.$watch (-> $location.search()), (search) ->
    page = parseInt(search.p, 10) or 1
    size = parseInt(search.pp, 10) or 8
    
    $scope.plunks = Plunk.query
      url: "#{url.api}/tags/#{$routeParams.tagname}/plunks"
      page: page
      size: size
  
  $scope.pageTo = (url) ->
    matches = url.match(/\?p=(\d+)&pp=(\d+)/i)
    
    search = $location.search()
    search.p = matches[1] or 1
    search.pp = matches[2] or 8
    
    $location.search(search)
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
    
  $scope.$parent.section = "plunks"
  
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
    
  $scope.$parent.section = "users"
  
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

module.controller "GalleryController", ["$scope", "$location", "$routeParams", "Plunk", "url", ($scope, $location, $routeParams, Plunk, url) ->
  $scope.$watch (-> $location.search()), (search) ->
    page = parseInt(search.p, 10) or 1
    size = parseInt(search.pp, 10) or 8
    
    ranking = $scope.ranking.name or $routeParams.ranking or "recent"
    
    suffixes =
      popular: "/popular"
      trending: "/trending"
      recent: ""
    
    $scope.plunks = Plunk.query
      url: "#{url.api}/plunks#{suffixes[ranking]}"
      page: page
      size: size
  
  $scope.pageTo = (url) ->
    matches = url.match(/\?p=(\d+)&pp=(\d+)/i)
    
    search = $location.search()
    search.p = matches[1] or 1
    search.pp = matches[2] or 8
    
    $location.search(search)
]
module.controller "TagsController", [ "$scope", ($scope) ->
  $scope.$parent.section = "tags"
  
]

module.controller "UsersController", [ "$scope", ($scope) ->
  $scope.$parent.section = "users"
  
]
