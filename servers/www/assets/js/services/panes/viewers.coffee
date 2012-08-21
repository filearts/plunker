#= require ../../vendor/jquery
#= require ../../vendor/angular

#= require ../../services/panels
#= require ../../services/session
#= require ../../services/scratch

module = angular.module("plunker.panels")

module.filter "iso8601", ->
  (value) -> (new Date(value)).toISOString()

module.directive "chatMessage", ["$timeout", ($timeout) ->
  restrict: "E"
  replace: true
  template: """
    <li class="message">
      <p class="body">{{message.body}}</p>
      <div class="meta">
        <a href="/users/{{message.user.login}}" ng-show="message.user" title="{{message.user.login}}">
          <img class="gravatar" ng-src="http://www.gravatar.com/avatar/{{message.user.gravatar_id}}?s=18&d=mm" />
          <span class="username existing">{{user.login}}</span>
        </a>
        <span ng-hide="message.user" title="Anonymous">
          <img class="gravatar" ng-src="http://www.gravatar.com/avatar/0?s=18&d=mm" />
          <span class="username">Anonymous</span>
        </span>
        <abbr class="timeago posted_at" title="{{message.posted_at | iso8601}}">{{message.posted_at | date:'MM/dd/yyyy @ h:mma'}}</abbr>
      </div>
    </li>
  """
  link: ($scope, $el, attrs) ->
    $timeout -> $(".timeago", $el).timeago()
]

module.run [ "$timeout", "$location", "panels", "session", "scratch", ($timeout, $location, panels, session, scratch) ->
  panels.push new class
    name: "viewers"
    order: 2
    size: 336
    title: "Show/hide the viewers pane"
    icon: "icon-group"
    template: """
      <div id="panel-viewers">
        <ul class="thumbnails">
          <li class="user" ng-repeat="(public_id, user) in users">
            <div class="thumbnail" title="{{user.login || 'Anonymous'}}">
              <img ng-src="http://www.gravatar.com/avatar/{{user.gravatar_id}}?s=32&d=mm" />
              <span class="username" title="{{user.login || 'Anonymous'}}">{{user.login || "Anonymous"}}</span>
            </div>
          </li>
        </ul>
        <form ng-submit="postChatMessage()">
          <input type="text" placeholder="Enter message..." class="span4" ng-model="message" />
        </form>
        <ul id="chat-messages">
          <chat-message message="message" ng-repeat="message in messages | orderBy:'posted_at':true"></chat-message>
        </ul>
      </div>
    """
          
    link: ($scope, el, attrs) ->
      self = @
      
      plunkRef = null
      chatRef = null
      usersRef = null
      presenceRef = null
      
      setOwnPresence = (presenceRef) -> $timeout ->
        presenceRef.removeOnDisconnect()
        presenceRef.set
          login: session.user?.login or "Anonymous"
          gravatar_id: session.user?.gravatar_id or 0
      
      handlePresenceValue = (snapshot) ->
        if snapshot.val() is null then setOwnPresence(presenceRef)
      
      handleUsersValue = (snapshot) ->
        if (users = snapshot.val()) isnt null then $scope.$apply ->
          $scope.users = users
          
          count = 0
          count++ for public_id of users
          
          self.badge =
            class: "badge"
            title: "There are #{count} users here"
            value: count
      
      $scope.$watch "session.user", (user) ->
        setOwnPresence(presenceRef) if presenceRef
      
      $scope.$watch ( -> $location.path().slice(1)), (id) ->
        if presenceRef
          presenceRef.off "value", handlePresenceValue
          usersRef.off "value", handleUsersValue
          presenceRef.remove()
          
          self.badge = null
        
        plunkRef = null
        chatRef = null
        
        return unless id

        plunkRef = new Firebase("http://gamma.firebase.com/filearts/#{id}/")
        chatRef = plunkRef.child("messages")
        usersRef = plunkRef.child("editors")
        presenceRef = usersRef.child(session.public_id)
        
        setOwnPresence(presenceRef)
          
        chatRef.on "value", handleChatValue
        chatRef.on "child_added", handleChatAdded
        
        presenceRef.on "value", handlePresenceValue
        usersRef.on "value", handleUsersValue
      
      handleChatValue = (snapshot) ->
        unless val = snapshot.val() is null then $timeout ->
          $scope.messages.concat(val)
      
      handleChatAdded = (snapshot) -> $timeout ->
        $scope.messages.push(snapshot.val())
      
      $scope.message = ""
      $scope.messages = []
      
      $scope.postChatMessage = ->
        console.log "chatRef", chatRef, $scope.message
        if chatRef and $scope.message
          message =
            body: $scope.message
            posted_at: +new Date
          
          if session.user then message.user =
            login: session.user.login
            gravatar_id: session.user.gravatar_id
          
          chatRef.push(message)
          
          $scope.message = ""
      
      $scope.scratch = scratch
      $scope.session = session
            
      
    deactivate: ($scope, el, attrs) ->
      
      @enabled = false
      
    activate: ($scope, el, attrs) ->
      
      @enabled = true
]
