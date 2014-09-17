require("./landing/landing.less");


var Angular = require("angular");


module.exports =
Angular.module("plunker.states.layout.landing", [
  require("plunker.components.columns").name,
  require("plunker.components.plunkCard").name,
  
  require("plunker.controllers.search").name,
  
  require("plunker.services.api").name,
  
  require("plunker.states.layout").name,
])

.config(["$stateProvider", function ($stateProvider) {
  $stateProvider.state("layout.landing", {
    url: "/",
    views: {
      'body': {
        template: require("./landing/landing.html"),
        controller: "LandingController",
        controllerAs: "state",
        resolve: {
          plunks: ["api", function (api) {
            return api.get("/search/plunker/public");
          }]
        }
      },
      'tb-left': {
        template: require("./landing/tb-left.html"),
      },
    },
  });
}])

.controller("LandingController", ["plunks", function (plunks) {
  this.plunks = plunks;
  
}])

;