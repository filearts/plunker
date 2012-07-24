#= require ../vendor/angular

module = angular.module "plunker.gallery", []

module.controller "GalleryController", ["$scope", "Plunk", ($scope, Plunk) ->
  $scope.plunks = Plunk.query()
]