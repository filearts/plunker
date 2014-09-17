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
      },
      'tb-left': {
        template: require("./landing/tb-left.html"),
      },
    },
  });
}])

.controller("LandingController", ["api", function (api) {
  var self = this;
  
  this.plunks = [];
  
  this.plunks.loading = api.get("/search/plunker/public");
  
  this.plunks.loading.then(function (plunks) {
    Angular.copy(plunks, self.plunks);
    self.plunks.meta = plunks.meta;
  });
  
  this.plunks.loading.finally(function () {
    delete self.plunks.loading;
  });
  
}])

;