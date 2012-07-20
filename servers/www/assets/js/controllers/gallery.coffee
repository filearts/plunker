class @GalleryController
  constructor: ($scope, Plunk) ->
    $scope.plunks = Plunk.query()