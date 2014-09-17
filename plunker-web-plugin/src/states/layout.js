require("./layout/layout.less");


var Angular = require("angular");


module.exports =
Angular.module("plunker.states.layout", [
  require("plunker.components.searchBox").name,
  require("plunker.components.userMenu").name,
  
  require("plunker.controllers.search").name,
])

.config(["$stateProvider", function ($stateProvider) {
  $stateProvider.state("layout", {
    virtual: true,
    views: {
      '': {
        template: require("./layout/layout.html"),
      },
    },
  });
}])

;