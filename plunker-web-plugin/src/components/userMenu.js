var Angular = require("angular");


module.exports =
Angular.module("plunker.compoments.userMenu", [
  require("plunker.services.visitor").name,
])

.directive("plunkerUserMenu", [function () {
  return {
    restrict: "EA",
    template: require("./userMenu/userMenu.html"),
    controller: "UserMenuController",
    controllerAs: "userMenu",
  };
}])

.controller("UserMenuController", ["visitor", function (visitor) {
  this.visitor = visitor;
}])

;
