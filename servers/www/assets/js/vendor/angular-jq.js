angular.module('ui.config', []).value('ui.config', {});

/**
 * General-purpose jQuery wrapper. Simply pass the plugin name as the expression.
 * 
 * It is possible to specify a default set of parameters for each jQuery plugin.
 * Under the jq key, namespace each plugin by that which will be passed to ui-jq.
 * Unfortunately, at this time you can only pre-define the first parameter.
 * @example { jq : { datepicker : { showOn:'click' } } }
 * 
 * @param ui-jq {string} The $elm.[pluginName]() to call.
 * @param [ui-options] {mixed} Expression to be evaluated and passed as options to the function
 *   	Multiple parameters can be separated by commas
 * 
 * @example <input ui-jq="datepicker" ui-options="{showOn:'click'},secondParameter,thirdParameter">
 */
angular.module('ui.directives').directive('uiJq', [function(uiConfig) {
	return {
		link: {
			post: function(scope, elm, attrs) {
        setTimeout(function(){
				  elm[attrs.uiJq]();
        }, 100);
			}
		}
	};
}]);