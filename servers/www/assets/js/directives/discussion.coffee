#= require ../vendor/angular-ui
#= require ../vendor/showdown
#= require ../vendor/prettify
#= require ../vendor/jquery.timeago
#= require ../vendor/jquery.cookie

#= require ../services/panels
#= require ../services/session
#= require ../services/scratch

genid = (len = 16, prefix = "", keyspace = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789") ->
  prefix += keyspace.charAt(Math.floor(Math.random() * keyspace.length)) while len-- > 0
  prefix


module = angular.module("plunker.discussion", [])

module.requires.push("ngSanitize")
module.requires.push("ui.directives")

module.filter "iso8601", ->
  (value) -> (new Date(value)).toISOString()
  
module.filter "markdown", ->
  converter = new Showdown.converter()
  (value) -> converter.makeHtml(value)


module.directive "chatMessage", ["$timeout", ($timeout) ->
  restrict: "E"
  replace: true
  template: """
    <li class="message">
      <div class="body" ng-bind-html="message.body | markdown"></div>
      <div class="meta">
        <a href="javascript:void(0)" ng-click="targetMessage(message.user)" title="{{message.user.name}}">
          <img class="gravatar" ng-src="http://www.gravatar.com/avatar/{{message.user.gravatar_id}}?s=18&d=mm" />
          <span class="username" ng-class="{existing: message.user.type == 'registered'}">{{message.user.name}}</span>
        </a>
        <abbr class="timeago posted_at" title="{{message.posted_at | iso8601}}">{{message.posted_at | date:'MM/dd/yyyy @ h:mma'}}</abbr>
      </div>
    </li>
  """
  link: ($scope, $el, attrs) ->
    converter = new Showdown.converter()
    
    $timeout ->
      $(".timeago", $el).timeago()
      prettyPrint()
    
    $scope.$watch "message.body", (body) ->
      $scope.markdown = converter.makeHtml(body)
]

module.directive "plunkerDiscussion", [ "$timeout", "$location", "panels", "session", "scratch", ($timeout, $location, panels, session, scratch) ->
  restrict: "E"
  replace: true
  scope:
    room: "="
  template: """
    <div class="plunker-discussion">
      <ul class="thumbnails">
        <li class="user" ng-repeat="(public_id, user) in users">
          <a href="javascript:void(0)" ng-click="targetMessage(user)" class="thumbnail" title="{{user.name}}">
            <img ng-src="http://www.gravatar.com/avatar/{{user.gravatar_id}}?s=32&d=mm" />
            <span class="username" title="{{user.name}}">{{user.name}}</span>
          </a>
        </li>
      </ul>
      <form ng-submit="postChatMessage()">
        <label>Discussion:</label>
        <textarea ui-keypress="{'ctrl-enter':'postChatMessage()'}" id="comments-message" type="text" placeholder="Enter message..." class="span4" ng-model="message"></textarea>
        <span class="help-block">Comments are markdown formatted.</span>
        <button class="btn btn-primary" ng-click="postChatMessage()">Comment</button>
      </form>
      <ul class="chat-messages">
        <chat-message message="message" ng-repeat="message in messages | orderBy:'posted_at':true"></chat-message>
      </ul>
    </div>
  """
        
  link: ($scope, el, attrs) ->
    self = @
    
    roomRef = null
    chatRef = null
    usersRef = null
    presenceRef = null
    
    handlePresenceValue = (snapshot) ->
      if snapshot.val() is null then setOwnPresence(presenceRef)
    
    handleUsersValue = (snapshot) ->
      if (users = snapshot.val()) isnt null then $scope.$apply ->
        angular.copy(users, $scope.users)

    handleChatAdded = (snapshot) -> $timeout ->
      $scope.messages.push(snapshot.val())
      
      $scope.$emit "discussion.message", snapshot.val()

    $scope.message = ""
    $scope.messages = []
    $scope.users = {}

    $scope.$watch ( -> session.user), (user) ->
      $scope.user = do ->
        if user 
          type: "registered"
          name: user.login
          pubId: session.public_id
          gravatar_id: user.gravatar_id
        else
          type: "anonymous"
          name: $.cookie("plnk_anonName") or do ->
            $.cookie "plnk_anonName", prompt("You are not logged in. Please provide a name for streaming:", genid(5, "Anon-")) or genid(5, "Anon-")
            $.cookie "plnk_anonName"
          pubId: session.public_id
          gravatar_id: 0
          
    $scope.$watch "user", (user) ->
      setOwnPresence(presenceRef) if presenceRef
    

    $scope.$watch "room", (room) ->
      # Reset messages
      $scope.messages.length = 0
      
      # Remove presenceRef
      if presenceRef
        presenceRef.off "value", handlePresenceValue
        usersRef.off "value", handleUsersValue
        presenceRef.remove()
      
      roomRef = null
      chatRef = null
      
      return unless room

      roomRef = new Firebase("https://filearts.firebaseio.com/rooms/#{room}/")
      chatRef = roomRef.child("messages")
      usersRef = roomRef.child("users")
      presenceRef = usersRef.child(session.public_id)
      
      setOwnPresence(presenceRef)
        
      chatRef.limit(50).on "child_added", handleChatAdded
      
      presenceRef.on "value", handlePresenceValue
      usersRef.on "value", handleUsersValue

    setOwnPresence = (presenceRef) -> $timeout ->
      presenceRef.removeOnDisconnect()
      presenceRef.set($scope.user)
    
    $scope.postChatMessage = ->
      if chatRef and $scope.message
        message =
          body: $scope.message
          posted_at: +new Date
          user: $scope.user
        
        chatRef.push(message)
        
        $scope.message = ""
    
    $scope.targetMessage = (user) ->
      unless $scope.message then $scope.message = "@#{user.name} "
      
      $("#comments-message").focus()
]
