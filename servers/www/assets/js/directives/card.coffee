#= require ../vendor/jquery
#= require ../vendor/jquery.timeago
#= require ../vendor/jquery.lazyload

#= require ../vendor/angular

#= require ../services/plunks

module = angular.module("plunker.card", ["plunker.plunks"])

module.filter "toHumanReadable", ->
  (value) -> value.toString() if value

module.directive "card", ["$timeout", ($timeout) ->
  restrict: "E"
  replace: true
  scope:
    model: "=model"
  template: """
    <li class="span3 plunk">
      <div class="thumbnail">
        <div class="pull-right owned" ng-show="model.token">
          <i class="icon-unlock" title="You created this Plunk"></i>
        </div>
        <h5 class="description" title="{{model.description}}">{{model.description}}</h5>
        <a ng-href="{{model.getHtmlUrl()}}">
          <img class="lazyload" ng-src="http://placehold.it/205x154&text=Loading..." data-original="http://immediatenet.com/t/l3?Size=1024x768&URL={{model.raw_url}}?_={{model.updated_at}}" />
        </a>
        <ul class="meta">
          <li class="edit">
            <a ng-href="{{model.getEditUrl()}}" target="_self" title="Edit this plunk">
              <i class="icon-edit" />
              <span class="live-editors">{{editors}}</span>
            </a>
          </li>
          <li class="viewers">
            <a ng-href="{{model.getHtmlUrl()}}" title="People currently viewing this plunk">
              <i class="icon-eye-open" />
              <span class="live-viewers">{{viewers}}</span>
            </a>
          </li>
          <li class="comments">
            <a ng-href="{{model.getCommentsUrl()}}" title="Join the discussion">
              <i class="icon-comments" />
              {{model.comments}}
            </a>
          </li>
  
        </ul>
        <ul class="extras">
          <li ng-show="model.source">
            <a ng-href="{{model.source.url}}" title="This plunk was imported. Click here to go to its source" target="_blank">
              <i class="icon-link" />
            </a>
          </li>
        </ul>
      </div>
      <div class="user">
        <a href="/users/{{model.user.login}}" ng-show="model.user">
          <img class="gravatar" ng-src="http://www.gravatar.com/avatar/{{model.user.gravatar_id}}?s=18&d=mm" />
          {{model.user.login}}
        </a>

        <span ng-hide="model.user">
          <img class="gravatar" ng-src="http://www.gravatar.com/avatar/0?s=18&d=mm" />
          Anonymous
        </span>
        <abbr class="timeago created_at" title="{{model.updated_at}}">{{model.updated_at | toHumanReadable}}</abbr>
      </div>
    </li>
  """
  link: ($scope, $el, attrs) ->
    $scope.viewers = 0
    $scope.editors = 0
    
    $scope.$watch 'model', (model) ->
      if model
        $(".timeago", $el).timeago() if model.updated_at
        $(".lazyload", $el).lazyload() if model.raw_url
        
        count_keys = (obj) ->
          count = 0
          count++ for key of obj
          count
        
        plunkRef = new Firebase("https://gamma.firebase.com/filearts/#{model.id}")
        
        viewersRef = plunkRef.child("viewers")
        
        viewersRef.on "value", (snapshot) -> $timeout ->
          $scope.viewers = count_keys(val) if val = snapshot.val()
        viewersRef.on "child_added", (snapshot) -> $timeout ->
          $scope.viewers ||= 0
          $scope.viewers += 1
        viewersRef.on "child_removed", (snapshot) -> $timeout ->
          $scope.viewers ||= 1
          $scope.viewers -= 1
        
        editorsRef = plunkRef.child("editors")
        
        editorsRef.on "value", (snapshot) -> $timeout ->
          $scope.editors = count_keys(val) if val = snapshot.val()
        editorsRef.on "child_added", (snapshot) -> $timeout ->
          $scope.viewers ||= 0
          $scope.editors += 1
        editorsRef.on "child_removed", (snapshot) -> $timeout ->
          $scope.viewers ||= 1
          $scope.editors -= 1
]