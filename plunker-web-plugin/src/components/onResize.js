var Angular = require("angular");
var Resize = require("on-resize");


module.exports =
Angular.module("plunker.components.onResize", [
])

.directive("onResize", ["$parse", function ($parse) {
  return {
    restrict: "A",
    link: function ($scope, $element, $attrs) {
      var fn = $parse($attrs.onResize);
      var handleResize = function (event) {
        $scope.$apply(function (){
          fn($scope, {$event: event});
        });
      };
      
      Resize.addResizeListener($element[0], handleResize);
      
      $scope.$on("$destroy", function () {
        Resize.removeResizeListener($element[0], handleResize);
      });
    }
  };
}])

;