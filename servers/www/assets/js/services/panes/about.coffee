#= require ../../directives/card

#= require ../../services/panels
#= require ../../services/scratch

module = angular.module("plunker.panels")

module.requires.push("plunker.card", "plunker.scratch")

module.run [ "$location", "panels", "scratch", ($location, panels, scratch) ->
  panels.push new class
    name: "about"
    order: 99
    size: 304
    title: "Information about the current plunk"
    icon: "icon-info-sign"
    template: """
      <div id="panel-about">
        <h1>{{plunk.description}}</h1>
        <p ng-show="plunk.user">
          <a href="/users/{{plunk.user.login}}">
            <img class="gravatar" ng-src="http://www.gravatar.com/avatar/{{plunk.user.gravatar_id}}?s=18&d=mm" />
            {{plunk.user.login}}
          </a>
        </p>
        <div ng-show="plunk.fork_of">
          <h3>Fork of</h3>
          <ul class="thumbnails cards"><card model="plunk.getForkOf()"></card></ul>
        </div>
        <div ng-show="plunk.forks">
          <h3>Forks</h3>
          <ul class="thumbnails cards"><card model="plunk" ng-repeat="plunk in plunk.getForks()"></card></ul>
        </div>
      </div>
    """
          
    link: ($scope, el, attrs) ->
      self = @
      
      $scope.$watch "scratch.plunk", (plunk) ->
        $scope.plunk = plunk
      
      $scope.scratch = scratch
      
    deactivate: ($scope, el, attrs) ->
      
      @enabled = false
      
    activate: ($scope, el, attrs) ->
      
      @enabled = true
]
