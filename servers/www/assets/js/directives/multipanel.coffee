#= require ../services/panels
#= require_tree ../services/panes

module = angular.module("plunker.multipanel", ["plunker.panels"])

module.directive "plunkerPanel", [ "$compile", ($compile) ->
  restrict: "E"
  replace: true
  template: """
    <div class="panel"></div>
  """
  link: ($scope, el, attrs) ->
    child = $compile($scope.panel.template or "")($scope)[0]
    el.append(child)

    $scope.panel.link($scope, child, attrs) if $scope.panel.link
    
    $scope.$watch "panels.active==panel", (isActive, wasActive) ->
      #return if isActive == wasActive
      
      if isActive then $scope.panel.activate($scope, el, attrs) if $scope.panel.activate
      else $scope.panel.deactivate($scope, el, attrs) if $scope.panel.deactivate

]

module.directive "plunkerMultipanel", [ "$location", "panels", ($location, panels) ->
  restrict: "E"
  replace: true
  scope: {}
  template: """
    <div>
      <plunker-panel ng-repeat="panel in panels" ng-show="panels.active==panel"></plunker-panel>
    </div>
  """
  link: ($scope, el, attrs) ->
    $scope.panels = panels
    
]