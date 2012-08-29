#= require ../vendor/jquery.timeago
#= require ../vendor/jquery.lazyload

#= require ../services/plunks

module = angular.module("plunker.card", ["plunker.plunks"])

module.filter "toHumanReadable", ->
  (value) -> value.toString() if value

module.directive "card", ["$timeout", "session", ($timeout, session) ->
  restrict: "E"
  replace: true
  scope:
    model: "=model"
  template: """
    <li class="span3 card">
      <div class="card thumbnail">
        <h5 class="description" title="{{model.description}}">
          <i ng-show="model.token" class="icon-unlock" title="You created this Plunk"></i>
          <a ng-href="{{model.getEditUrl()}}">
            {{model.description}}
          </a>
        </h5>
        <div class="preview">
          <a class="preview" ng-click="showPreview()" ng-href="{{model.getHtmlUrl()}}">
            <img class="preview lazyload" ng-src="http://placehold.it/205x154&text=Loading..." data-original="http://immediatenet.com/t/l3?Size=1024x768&URL={{model.raw_url}}?_={{model.updated_at}}" />
          </a>
          <div class="hover">
            <ul class="tags">
              <li ng-repeat="tag in model.tags">
                <a ng-href="/tags/{{tag}}">{{tag}}</a>
              </li>
            </ul>
          </div>
        </div>
        <ul class="meta">
          <li class="edit">
            <a ng-href="{{model.getEditUrl()}}" title="Edit this plunk">
              <i class="icon-edit" />
              <span class="live-editors">{{editors}}</span>
            </a>
          </li>
          <li class="comments">
            <a ng-href="{{model.getEditUrl()}}?p=comments" title="Join the discussion">
              <i class="icon-comments" />
              <span class="live-comments">{{comments}}</span>
            </a>
          </li>
          <li class="votes" ng-switch on="!!session.user">
            <span ng-switch-when="false">
              <i class="icon-thumbs-up" />
              <span class="thumbs-up">{{model.thumbs || 0 | number}}</span>
            </span>
            <a ng-switch-when="true" ng-href="{{model.getHtmlUrl()}}" ng-click="thumbsUp(model)" title="Number of thumbs-up">
              <i class="icon-thumbs-up" />
              <span class="thumbs-up">{{model.thumbs || 0 | number}}</span>
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
        <a ng-href="/users/{{model.user.login}}" ng-show="model.user">
          <img class="gravatar" ng-src="http://www.gravatar.com/avatar/{{model.user.gravatar_id}}?s=18&d=mm" />
          {{model.user.login}}
        </a>

        <span ng-hide="model.user">
          <img class="gravatar" ng-src="http://www.gravatar.com/avatar/0?s=18&d=mm" />
          Anonymous
        </span>
        <abbr class="timeago created_at" title="{{model.updated_at}}">{{model.updated_at}}</abbr>
      </div>
    </li>
  """
  link: ($scope, $el, attrs) ->
    $scope.viewers = 0
    $scope.editors = 0
    $scope.comments = 0
    
    $scope.session = session
    
    $scope.thumbsUp = (plunk) ->
      
    
    $scope.$watch "model.updated_at", (updated_at) -> $(".timeago", $el).timeago() if updated_at
    $scope.$watch "model.raw_url", (raw_url) -> $(".lazyload", $el).lazyload() if raw_url
    
    $scope.$watch 'model', (model) ->
      if model
        count_keys = (obj) ->
          count = 0
          count++ for key of obj
          count
        
        plunkRef = new Firebase("https://gamma.firebase.com/filearts/#{model.id}")
        
        viewersRef = plunkRef.child("viewers")
        viewersRef.on "child_added", (snapshot) -> $timeout -> $scope.viewers += 1
        viewersRef.on "child_removed", (snapshot) -> $timeout -> $scope.viewers -= 1
        
        editorsRef = plunkRef.child("editors")
        editorsRef.on "child_added", (snapshot) -> $timeout -> $scope.editors += 1
        editorsRef.on "child_removed", (snapshot) -> $timeout -> $scope.editors -= 1

        messagesRef = plunkRef.child("messages")
        messagesRef.on "child_added", (snapshot) -> $timeout -> $scope.comments += 1

]