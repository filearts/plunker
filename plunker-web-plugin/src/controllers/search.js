var Angular = require("angular");


module.exports =
Angular.module("plunker.controllers.search", [
])

.controller("SearchController", ["$scope", "$state", function ($scope, $state) {
  var self = this;
  
  this.query = "";
  
  this.reset = function () {
    this.query = "";
  };
  
  this.search = function (query, noinherit) {
    return $state.go("layout.search", {q: query}, {inherit: !noinherit});
  };
  
  $scope.$on("$stateChangeSuccess", function (e, toState, toParams) {
    if (!toParams.q) self.query = "";
  });
}])

;