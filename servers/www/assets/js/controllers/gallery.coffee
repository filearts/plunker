#= require ../vendor/angular

module = angular.module "plunker.gallery", []

module.controller "GalleryController", ["$scope", "$location", "Plunk", ($scope, $location, Plunk) ->
  search = $location.search()
  
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