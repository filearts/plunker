require("animate.css/animate.css");

require("./search/search.less");


var Angular = require("angular");
var _ = require("lodash");


module.exports =
Angular.module("plunker.states.layout.search", [
  require("plunker.components.columns").name,
  require("plunker.components.plunkCard").name,
  
  require("plunker.controllers.search").name,
  
  require("plunker.services.api").name,
  
  require("plunker.states.layout").name,
])

.config(["$stateProvider", function ($stateProvider) {
  $stateProvider.state("layout.search", {
    url: "/search?tags&packages&q",
    reloadOnSearch: true,
    views: {
      'body': {
        template: require("./search/search.html"),
        controller: "SearchStateController",
        controllerAs: "state",
      },
      'tb-left': {
        template: require("./landing/tb-left.html"),
      },
    },
  });
}])

.controller("SearchStateController", ["$stateParams", "api", function ($stateParams, api) {
  var self = this;
  
  this.plunks = [];
  
  this.plunks.loading = api.get("/search/plunker/public", {
    tags: $stateParams.tags || [],
    packages: $stateParams.packages || [],
    q: $stateParams.q || "",
  });
  
  this.plunks.loading.then(function (plunks) {
    Angular.copy(plunks, self.plunks);
    self.plunks.meta = plunks.meta;
  });
  
  this.plunks.loading.finally(function () {
    delete self.plunks.loading;
  });
  
  this.filters = {
    query: $stateParams.q,
    tags: _.filter(_.isArray($stateParams.tags) ? $stateParams.tags : [$stateParams.tags], Boolean),
    packages: _.filter(_.isArray($stateParams.packages) ? $stateParams.packages : [$stateParams.packages], Boolean),
  };
  
  this.contains = function (arr, val) {
    return _.isArray(arr) && arr.indexOf(val) >= 0;
  };
  
  this.toggle = function (arr, val) {
    return this.contains(arr, val) ? this.without(arr, val) : this.with(arr, val);
  };
  
  this.with = function (arr, val) {
    return _(arr).concat(val).filter(Boolean).unique().value();
  };
  
  this.without = function (arr, val) {
    var without = _.without(arr, val);
    
    return without.length ? without : null;
  };
}])

;