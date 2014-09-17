require("./searchBox/searchBox.less");


var Angular = require("angular");


module.exports =
Angular.module("plunker.compoments.searchBox", [
])

.directive("plunkerSearchBox", [function () {
  return {
    restrict: "EA",
    template: require("./searchBox/searchBox.html"),
    controller: "SearchController",
    controllerAs: "search",
  };
}])

;
