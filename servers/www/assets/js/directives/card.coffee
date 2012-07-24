#= require ../vendor/jquery
#= require ../vendor/jquery.timeago
#= require ../vendor/jquery.lazyload

#= require ../vendor/angular

#= require ../services/plunks

module = angular.module("plunker.card", ["plunker.plunks"])

module.filter "toHumanReadable", ->
  (value) -> value.toString()

module.directive "card", ->
  restrict: "E"
  replace: true
  template: """
    <li class="span3 plunk">
      <div class="thumbnail">
        <h5 class="description" title="{{plunk.description}}">{{plunk.description}}</h5>
        <a href="{{plunk.html_url}}">
          <img class="lazyload" ng-src="http://placehold.it/205x154&text=Loading..." data-original="http://immediatenet.com/t/l3?Size=1024x768&URL={{plunk.raw_url}}?_={{plunk.updated_at}}" />
        </a>
        <ul class="meta">
          <li class="edit">
            <a href="{{plunk.edit_url}}" title="Edit this plunk">
              <i class="icon-edit" />
              <span class="live-editors">0</span>
            </a>
          </li>
          <li class="viewers">
            <a href="{{plunk.html_url}}" title="People currently viewing this plunk">
              <i class="icon-eye-open" />
              <span class="live-viewers">0</span>
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
    $scope.$watch 'plunk', (plunk) ->
      $(".timeago", $el).timeago() if plunk.updated_at
      $(".lazyload", $el).lazyload() if plunk.raw_url
