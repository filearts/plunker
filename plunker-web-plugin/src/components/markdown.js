require("./markdown/markdown.less");


var Ace = require("ace");
var Angular = require("angular");
var Marked = require("marked");


module.exports =
Angular.module("plunker.components.markdown", [
])

.directive("plunkerMarkdown", ["$q", "$sce", function ($q, $sce) {
  var Dom = Ace.require("ace/lib/dom");
  var importedCss = false;
  var modules = {};
  
  var loadModuleAsync = function (moduleName) {
    if (modules[moduleName]) return modules[moduleName];
    
    var dfd = $q.defer();
    
    Ace.config.loadModule(moduleName, function (moduleImpl) {
      dfd.resolve(moduleImpl);
    });
    
    modules[moduleName] = dfd.promise;
    
    return modules[moduleName];
  };
  
  return {
    restrict: "EA",
    link: function ($scope, $element, $attrs) {
      $element.addClass("markdown");
      
      if ($attrs.plunkerMarkdown) $scope.$watch($attrs.plunkerMarkdown, render);
      else render($element.text());
      
      function render (markdown) {
        if (!markdown) markdown = "";
        
        var options = {
          highlight: function (code, lang, callback) {
            $q.all([loadModuleAsync("ace/ext/static_highlight"), loadModuleAsync("ace/mode/" + lang), loadModuleAsync("ace/theme/textmate")]).then(function (modules) {
              var rendered = modules[0].renderSync(code.trim(), new modules[1].Mode(), modules[2], 1, true);
              
              if (!importedCss) {
                Dom.importCssString(rendered.css, "ace_static_highlight");
                importedCss = true;
              }
              
              callback(null, rendered.html);
            });
          }
        };
        
        Marked(markdown.trim(), options, function (err, markup) {
          if (!err) $element.html($sce.trustAsHtml(markup));
        });
      }
    }
  };
}])

;