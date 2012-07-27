#= require ../../bootstrap/js/bootstrap-all

#= require ../services/session

module = angular.module("plunker.userpanel", ["plunker.session"])

module.directive "userpanel", [ ->
  restrict: "E"
  replace: true
  template: """
    <div id="userpanel" class="pull-right">
      <div class="btn-group" ng-show="session.user.id">
        <button class="user-menu btn dropdown-toggle" data-toggle="dropdown">
          <img class="gravatar" src="http://www.gravatar.com/avatar/{{session.user.gravatar_id}}?s=20" />
          <span class="text">{{session.user.login}}</span>
          <b class="caret" />
        </button>
        <ul class="dropdown-menu">
          <li>
            <a class="logout" href="javascript:void(0)" ng-click="session.logout()">Logout</a>
          </li>
        </ul>
      </div>
      <div class="btn-group" ng-hide="session.user.id">
        <button class="user-login btn dropdown-toggle" data-toggle="dropdown">
          <i class="icon-user" />
          <span class="text">Sign in</span>
          <span class="caret"></span>
        </button>
        <ul class="dropdown-menu">
          <li>
            <a class="login login-github" data-service="github" href="javascript:void(0)" ng-click="session.login()">
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