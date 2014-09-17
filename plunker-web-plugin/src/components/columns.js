var Angular = require("angular");
var Resize = require("on-resize");
var _ = require("lodash");


module.exports =
Angular.module("plunker.components.columns", [
  require("angular-animate").name,
])

.directive("plunkerColumns", [ "$animate", "$parse", function ($animate, $parse) {
  return {
    restrict: "A",
    transclude: "element",
    link: function ($scope, $element, $attrs, ctrl, $transclude) {
      var columns = [];
      var parentEl = $element.parent()[0];
      
      var reflow = function (force) {
        var breakpoints = $parse($attrs.plunkerColumns)($scope);
        var width = parentEl.clientWidth;
        var match = _.reduce(breakpoints, function (result, columns, minWidth) {
          minWidth = parseInt(minWidth, 10);
          
          if (minWidth <= width && minWidth > result.minWidth) {
            result.columns = columns;
            result.minWidth = minWidth;
          }
          return result;
        }, {minWidth: 0, columns: 1});
        
        if (!force && columns.length === match.columns) return;
        
        var source = $parse($attrs.source)($scope);
        
        match.columns = Math.min(source.length, match.columns);
        
        // Step 1: Remove excess columns
        for (var i = match.columns; i < columns.length; i++) {
          $animate.leave(columns[i].clone);
          columns[i].scope.$destroy();
        }
        
        // Drop extra columns
        columns.length = Math.min(columns.length, match.columns, source.length);
        
        var previousNode = columns.length ? columns[columns.length - 1].clone : $element;
        
        // Step 2: Add additional columns
        for (var i = columns.length; i < match.columns; i++) {
          $transclude(function (clone, scope) {
            columns[i] = {
              clone: clone,
              scope: scope,
            };
            
            scope.column = [];
            
            $animate.enter(clone, null, previousNode);
            
            previousNode = clone;
          });
        }
        
        // Step 3: Clear all column scopes
        _.forEach(columns, function (column) {
          column.scope.column.length = 0;
        });
        
        // Step 4: Re-allocate the items
        _.forEach(source, function (item, i) {
          var col = i % columns.length;
          var column = columns[col];
          
          column.scope.column.push(item);
        });
      };
      
      var onResize = function () {
        $scope.$apply(_.partial(reflow, false));
      };
      
      Resize.addResizeListener(parentEl, onResize);
      
      $scope.$watchCollection($attrs.source, _.partial(reflow, true));
      
      $scope.$on("$destroy", function () {
        Resize.removeResizeListener(parentEl, onResize);
      });
    }
  };
}])

;