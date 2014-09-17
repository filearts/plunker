require("./plunkCard/plunkCard.less");


var Angular = require("angular");
var Summarize = require("summarize-markdown");
var _ = require("lodash");

module.exports =
Angular.module("plunker.compoments.plunkCard", [
  require("angular-timeago").name,
  
  require("plunker.services.visitor").name,
])

.directive("plunkerCard", [function () {
  return {
    restrict: "E",
    scope: {
      plunk: "="
    },
    template: require("./plunkCard/plunkCard.html"),
    //controller: "CardController",
    //controllerAs: "card",
  };
}])

.directive("plunkerCardImage", ["config", function (config) {
  return {
    restrict: "A",
    scope: {
      plunk: "=plunkerCardImage"
    },
    link: function ($scope, $element, $attr) {
      var reset = function (message) {
        $element.attr("src", "http://placehold.it/300x150&text=" + (message || ""));
      };
      
      reset("Loading...");
      
      $scope.$watchGroup(["plunk.id", "plunk.updated_at"], function (updated) {
        var plunkId = updated[0];
        var updatedAt = updated[1];
        
        if (plunkId) $element.attr("src", config.url.shot + "/" + $scope.plunk.id + ".png?d=" + updatedAt);
        else reset("Invalid plunk");
      });
      
      $element.on("error", _.partial(reset, "Error loading image"));
      
      $scope.$on("$destroy", function () {
        $element.off("error", reset);
      });
    }
  };
}])


//.controller("CardController", ["$scope", function ($scope) {
//  this.plunk = $scope.plunk;
//}])

.filter("summarizeMarkdown", [function () {
  return function (value, max) {
    if (!value) return value;
    
    var summarized = Summarize(value);
    
    if (max) {
      max = parseInt(max, 10);
      if (summarized.length > max) summarized = summarized.slice(0, max - 1) + "…";
    }
    
    return summarized;
  };
}])

;
