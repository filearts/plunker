require("bootstrap/less/bootstrap.less");

var config = CONFIG;

if (window.xdomain) {
  var slaves = {};
  
  slaves[config.url.api] = "/proxy.html";
  
  window.xdomain.slaves(slaves);
  window.xdomain.debug = true;
}

var Angular = require("angular");


module.exports = 
Angular.module('plunker', [
  require("angular-animate").name,
  
  require("angular-ui-bootstrap").name,
  require("angular-ui-router").name,
  
  require("plunker.states.editor").name,
  
  require("plunker.states.layout.search").name,
  require("plunker.states.layout.landing").name,
  require("plunker.states.layout.plunk").name,
])

.constant("config", config) // CONFIG is injected by Webpack

.config(["$tooltipProvider", function ($tooltipProvider) {
  $tooltipProvider.options({
    appendToBody: true,
    popupDelay: 100,
  });
}])


.config(["$locationProvider", function ($locationProvider) {
  $locationProvider.html5Mode(true).hashPrefix("!");
}])

.run(["$rootScope", function ($rootScope) {
  $rootScope.title = "Plunker";
  
  $rootScope.$on("$stateChangeSuccess", function (e, toState) {
    $rootScope.title = toState.title || "Plunker";
  });
}])

;