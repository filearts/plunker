var Angular = require("angular");


module.exports =
Angular.module("plunker.states.editor", [
])

.config(["$stateProvider", function ($stateProvider) {
  $stateProvider.state("editor", {
    url: "/edit/{plunkId}",
    params: {
      plunkId: {
        default: "",
      },
    },
  });
}])

.run(["$rootScope", "$window", function ($rootScope, $window) {
  $rootScope.$on("$stateChangeStart", function (event, toState, toParams) {
    if (toState.name === "editor") {
      event.preventDefault();
      $window.location = "http://plnkr.co/edit/" + (toParams.plunkId || "");
    }
  });
}])

;