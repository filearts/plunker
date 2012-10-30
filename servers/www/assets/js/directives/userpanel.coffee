#= require ../services/session

module = angular.module("plunker.userpanel", ["plunker.session"])

module.directive "plnkrPress", ["$parse", ($parse) ->
  (scope, element, attrs) ->
    tapping = false
    fn = $parse(attrs["plnkrPress"])
    
    element.bind 'touchstart', (e) -> tapping = true
    element.bind 'touchmove', (e) -> tapping = false
    element.bind 'touchend', (e) -> if tapping then scope.$apply -> fn(scope, $event: e)
    element.bind 'click', (e) -> scope.$apply -> fn(scope, $event: e)
]

module.directive "userpanel", [ ->
  restrict: "E"
  replace: true
  template: """
    <div id="userpanel" class="pull-right">
      <div class="btn-group" ng-show="session.user.id">
        <button class="user-menu btn dropdown-toggle" data-toggle="dropdown" title="User options">
          <img class="gravatar" src="http://www.gravatar.com/avatar/{{session.user.gravatar_id}}?s=20" />
          <span class="text shrink">{{session.user.login}}</span>
          <b class="caret" />
        </button>
        <ul class="dropdown-menu">
          <li>
            <a href="/users/{{session.user.login}}">My Profile</a>
          </li>
          <li>
            <a href="/users/{{session.user.login}}/thumbed">My thumbed plunks</a>
          </li>
          <li class="divider"></li>
          <li>
            <a class="logout" href="javascript:void(0)" plnkr-press="session.logout()">Logout</a>
          </li>
        </ul>
      </div>
      <div class="btn-group" ng-hide="session.user.id">
        <button class="user-login btn dropdown-toggle" data-toggle="dropdown" title="Sign in">
          <i class="icon-user" />
          <span class="text shrink">Sign in</span>
          <span class="caret"></span>
        </button>
        <ul class="dropdown-menu">
          <li>
            <a class="login login-github" data-service="github" href="javascript:void(0)" plnkr-press="session.login()">
              <i class="icon-github" />
              Sign in with Github
            </a>
          </li>
        </ul>
      </div>
    </div>
  """
  controller: ["$scope", "session", ($scope, session) ->
    $scope.session = session
  ]
]