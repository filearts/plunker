module = angular.module("plunker.whitelist", [])

module.service "whitelist", ["$rootScope", "$location", "$window", ($rootScope, $location, $window) ->
  whitelist = []
  
  $rootScope.$on "$locationChangeStart", (e) ->
    for exception in whitelist
      if $location.path().match(exception)
        #TODO: $window service reacted too slowly. possible to accelerate?
        window.location = $location.path()
      
  whitelist
]