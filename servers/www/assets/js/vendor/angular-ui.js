/**
 * AngularUI for AngularJS
 * v0.1.0
 * 
 * @link http://angular-ui.github.com/
 */

angular.module('ui.config', []).value('ui.config', {});
angular.module('ui.filters', ['ui.config']);
angular.module('ui.directives', ['ui.config']);
angular.module('ui', [
  'ui.filters', 
  'ui.directives',
  'ui.config'
]);

angular.module('ui.directives').directive('uiKeypress', ['$parse', function ($parse) {
  return {
    link: function (scope, elm, attrs) {
      var keysByCode = {
        8: 'backspace',
        9: 'tab',
        13: 'enter',
        27: 'esc',
        32: 'space',
        33: 'pageup',
        34: 'pagedown',
        35: 'end',
        36: 'home',
        37: 'left',
        38: 'up',
        39: 'right',
        40: 'down',
        45: 'insert',
        46: 'delete'
      };

      var params, paramsParsed, expression, keys, combinations = [];
      try {
        params = scope.$eval(attrs.uiKeypress);
        paramsParsed = true;
      } catch (error) {
        params = attrs.uiKeypress.split(/\s+and\s+/i);
        paramsParsed = false;
      }

      // Prepare combinations for simple checking
      angular.forEach(params, function (v, k) {
        var combination = {};
        if (paramsParsed) {
          // An object passed
          combination.expression = $parse(v);
          combination.keys = k;
        } else {
          // A string passed
          v = v.split(/\s+on\s+/i);
          combination.expression = $parse(v[0]);
          combination.keys = v[1];
        }

        keys = {};
        angular.forEach(combination.keys.split('-'), function (value) {
          keys[value] = true;
        });
        combination.keys = keys;
        combinations.push(combination);
      });

      // Check only mathcing of pressed keys one of the conditions
      elm.bind('keydown', function (event) {
        // No need to do that inside the cycle
        var altPressed = event.metaKey || event.altKey;
        var ctrlPressed = event.ctrlKey;
        var shiftPressed = event.shiftKey;

        // Iterate over prepared combinations
        angular.forEach(combinations, function (combination) {

          var mainKeyPressed = (combination.keys[keysByCode[event.keyCode]] || combination.keys[event.keyCode.toString()]) || false;

          var altRequired = combination.keys.alt || false;
          var ctrlRequired = combination.keys.ctrl || false;
          var shiftRequired = combination.keys.shift || false;

          if (mainKeyPressed &&
            ( altRequired == altPressed   ) &&
            ( ctrlRequired == ctrlPressed  ) &&
            ( shiftRequired == shiftPressed )
            ) {
            // Run the function
            scope.$apply(function () {
              combination.expression(scope, { '$event': event });
            });
          }
        });
      });
    }
  };
}]);
angular.module('ui.directives').directive('uiSelect2', ['ui.config', '$http', function (uiConfig, $http) {
  var options = {};
  if (uiConfig.select2) {
    angular.extend(options, uiConfig.select2);
  }
  return {
    require: '?ngModel',
    compile: function (tElm, tAttrs) {
      var watch,
        repeatOption,
        isSelect = tElm.is('select'),
        isMultiple = (tAttrs.multiple !== undefined);

      // Enable watching of the options dataset if in use
      if (isSelect) {
        repeatOption = tElm.find('option[ng-repeat]');
        if (repeatOption.length) {
          watch = repeatOption.attr('ng-repeat').split(' ').pop();
        }
      }

      return function (scope, elm, attrs, controller) {
        // instance-specific options
        var opts = angular.extend({}, options, scope.$eval(attrs.uiSelect2));

        if (isSelect) {
          // Use <select multiple> instead
          delete opts.multiple;
          delete opts.initSelection;
        } else if (isMultiple) {
          opts.multiple = true;
        }

        if (controller) {
          // Watch the model for programmatic changes
          controller.$render = function () {
            if (isSelect) {
              elm.select2('val', controller.$modelValue);
            } else {
              if (isMultiple && !controller.$modelValue) {
                elm.select2('data', []);
              } else {
                var items = [];
                
                angular.forEach(controller.$modelValue, function(item) {
                  items.push({id: item, text: item});
                });
                
                elm.select2('data', items);
              }
            }
          };


          // Watch the options dataset for changes
          if (watch) {
            scope.$watch(watch, function (newVal, oldVal, scope) {
              if (!newVal) return;
              // Delayed so that the options have time to be rendered
              setTimeout(function () {
                elm.select2('val', controller.$viewValue);
                // Refresh angular to remove the superfluous option
                elm.trigger('change');
              });
            });
          }

          if (!isSelect) {
            // Set the view and model value and update the angular template manually for the ajax/multiple select2.
            elm.bind("change", function () {
              scope.$apply(function () {
                controller.$setViewValue(elm.select2('data'));
              });
            });

            if (opts.initSelection) {
              var initSelection = opts.initSelection;
              opts.initSelection = function (element, callback) {
                initSelection(element, function (value) {
                  console.log("Initial bvalue", value);
                  controller.$setViewValue(value);
                  callback(value);
                });
              };
            }
          }
        }

        attrs.$observe('disabled', function (value) {
          elm.select2(value && 'disable' || 'enable');
        });

        // Set initial value since Angular doesn't
        elm.val(scope.$eval(attrs.ngModel));

        // Initialize the plugin late so that the injected DOM does not disrupt the template compiler
        setTimeout(function () {
          elm.select2(opts);
        });
      };
    }
  };
}]);