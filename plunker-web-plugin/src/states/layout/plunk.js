require("./plunk/plunk.less");


var Angular = require("angular");


module.exports =
Angular.module("plunker.states.layout.plunk", [
  require("plunker.components.markdown").name,
  
  require("plunker.services.api").name,
  
  require("plunker.states.layout").name,
])

.config(["$stateProvider", function ($stateProvider) {
  $stateProvider.state("layout.plunk", {
    url: "/plunks/{plunkId}",
    views: {
      'body': {
        template: require("./plunk/plunk.html"),
        controller: "PlunkController",
        controllerAs: "page",
        resolve: {
          plunk: ["$stateParams", "api", function ($stateParams, api) {
            return api.get("/plunks/" + $stateParams.plunkId);
          }]
        }
      },
      'tb-left': {
        template: require("./plunk/tb-left.html"),
        controller: "PlunkController",
        controllerAs: "page",
        resolve: {
          plunk: ["$stateParams", "api", function ($stateParams, api) {
            return api.get("/plunks/" + $stateParams.plunkId);
          }]
        }
      },
    },
  });
}])

.controller("PlunkController", ["plunk", function (plunk) {
  this.plunk = plunk;
}])

.directive("plunkerRunner", ["$sce", "config", function ($sce, config) {
  return {
    restrict: "EA",
    scope: {
      plunk: "=",
    },
    template: require("./plunk/runner.html"),
    link: function ($scope, $element, $attrs) {
      $scope.preview_url = $sce.trustAsResourceUrl(config.url.run + "/plunks/" + $scope.plunk.id + "/");
    }
  };
}])

;