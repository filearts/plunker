#= require ../vendor/jquery
#= require ../vendor/jquery.timeago
#= require ../vendor/jquery.lazyload

#= require ../vendor/angular

#= require ../services/plunks

module = angular.module("plunker.card", ["plunker.plunks"])

module.filter "toHumanReadable", ->
  (value) -> value.toString()

module.directive "card", ["$timeout", ($timeout) ->
  restrict: "E"
  replace: true
  template: """
    <li class="span3 plunk">
      <div class="thumbnail">
        <div class="pull-right owned" ng-show="plunk.token">
          <i class="icon-unlock" title="You created this Plunk"></i>
        </div>
        <h5 class="description" title="{{plunk.description}}">{{plunk.description}}</h5>
        <a href="{{plunk.html_url}}">
          <img class="lazyload" ng-src="http://placehold.it/205x154&text=Loading..." data-original="http://immediatenet.com/t/l3?Size=1024x768&URL={{plunk.raw_url}}?_={{plunk.updated_at}}" />
        </a>
        <ul class="meta">
          <li class="edit">
            <a href="{{plunk.edit_url}}" title="Edit this plunk">
              <i class="icon-edit" />
              <span class="live-editors">{{editors}}</span>
            </a>
          </li>
          <li class="viewers">
            <a href="{{plunk.html_url}}" title="People currently viewing this plunk">
              <i class="icon-eye-open" />
              <span class="live-viewers">{{viewers}}</span>
            </a>
          </li>
          <li class="comments">
            <a href="{{plunk.comments_url}}" title="Join the discussion">
              <i class="icon-comments" />
              {{plunk.comments}}
            </a>
          </li>
  
        </ul>
        <ul class="extras">
          <li ng-show="plunk.source">
            <a href="{{plunk.source.url}}" title="This plunk was imported. Click here to go to its source" target="_blank">
              <i class="icon-link" />
            </a>
          </li>
        </ul>
      </div>
      <div class="user">
        <a href="/users/{{plunk.user.login}}" ng-show="plunk.user">
          <img class="gravatar" ng-src="http://www.gravatar.com/avatar/{{plunk.user.gravatar_id}}?s=18&d=mm" />
          {{plunk.user.login}}
        </a>

        <span ng-hide="plunk.user">
          <img class="gravatar" ng-src="http://www.gravatar.com/avatar/0?s=18&d=mm" />
          Anonymous
        </span>
        <abbr class="timeago created_at" title="{{plunk.updated_at}}">{{plunk.updated_at | toHumanReadable}}</abbr>
      </div>
    </li>
  """
  link: ($scope, $el, attrs) ->
    $scope.viewers = 0
    $scope.editors = 0
    
    $scope.$watch 'plunk', (plunk) ->
      $(".timeago", $el).timeago() if plunk.updated_at
      $(".lazyload", $el).lazyload() if plunk.raw_url
      
      count_keys = (obj) ->
        count = 0
        count++ for key of obj
        count
      
      plunkRef = new Firebase("https://gamma.firebase.com/filearts/#{plunk.id}")
      
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