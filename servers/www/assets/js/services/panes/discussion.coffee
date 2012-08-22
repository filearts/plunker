#= require ../../vendor/jquery
#= require ../../vendor/angular
#= require ../../vendor/angular-sanitize
#= require ../../vendor/angular-ui
#= require ../../vendor/showdown
#= require ../../vendor/prettify

#= require ../../services/panels
#= require ../../services/session
#= require ../../services/scratch

module = angular.module("plunker.panels")

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
        <a href="javascript:void(0)" ng-click="targetMessage(message.user)" ng-show="message.user" title="{{message.user.login}}">
          <img class="gravatar" ng-src="http://www.gravatar.com/avatar/{{message.user.gravatar_id}}?s=18&d=mm" />
          <span class="username existing">{{message.user.login}}</span>
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
    converter = new Showdown.converter()
    
    $timeout ->
      $(".timeago", $el).timeago()
      prettyPrint()
    
    $scope.$watch "message.body", (body) ->
      $scope.markdown = converter.makeHtml(body)
]

module.run [ "$timeout", "$location", "panels", "session", "scratch", ($timeout, $location, panels, session, scratch) ->
  panels.push new class
    name: "comments"
    order: 2
    size: 330
    title: "Live discussion"
    icon: "icon-comments"
    template: """
      <div id="panel-discussion">
        <ul class="thumbnails">
          <li class="user" ng-repeat="(public_id, user) in users">
            <a href="javascript:void(0)" ng-click="targetMessage(user)" class="thumbnail" title="{{user.login || 'Anonymous'}}">
              <img ng-src="http://www.gravatar.com/avatar/{{user.gravatar_id}}?s=32&d=mm" />
              <span class="username" title="{{user.login || 'Anonymous'}}">{{user.login || "Anonymous"}}</span>
            </a>
          </li>
        </ul>
        <form ng-submit="postChatMessage()">
          <label>Discussion:</label>
          <textarea ui-keypress="{'ctrl-enter':'postChatMessage()'}" id="comments-message" type="text" placeholder="Enter message..." class="span4" ng-model="message"></textarea>
          <span class="help-block">Comments are markdown formatted.</span>
          <button class="btn btn-primary" ng-click="postChatMessage()">Comment</button>
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

      $scope.message = ""
      $scope.messages = []
      $scope.users = {}
      
      self.new_events = 0
      
      setOwnPresence = (presenceRef) -> $timeout ->
        presenceRef.removeOnDisconnect()
        presenceRef.set
          login: session.user?.login or "Anonymous"
          gravatar_id: session.user?.gravatar_id or 0
      
      handlePresenceValue = (snapshot) ->
        if snapshot.val() is null then setOwnPresence(presenceRef)
      
      handleUsersValue = (snapshot) ->
        if (users = snapshot.val()) isnt null then $scope.$apply ->
          angular.copy(users, $scope.users)
      
      $scope.$watch "session.user", (user) ->
        setOwnPresence(presenceRef) if presenceRef
      
      handleChatAdded = (snapshot) -> $timeout ->
        $scope.messages.push(snapshot.val())
        
        unless self.enabled
          self.new_events += 1
          
          self.badge =
            class: "badge #{self.badge_class_prefix}"
            title: "You have missed #{self.new_events} events(s)"
            value: self.new_events
      
      $scope.$watch ( -> $location.path().slice(1)), (id) ->
        $scope.messages.length = 0
        
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
          
        chatRef.on "child_added", handleChatAdded
        
        presenceRef.on "value", handlePresenceValue
        usersRef.on "value", handleUsersValue
      
      $scope.postChatMessage = ->
        if chatRef and $scope.message
          message =
            body: $scope.message
            posted_at: +new Date
          
          if session.user then message.user =
            login: session.user.login
            gravatar_id: session.user.gravatar_id
          
          chatRef.push(message)
          
          $scope.message = ""
      
      $scope.targetMessage = (user) ->
        unless $scope.message then $scope.message = "@#{user.login} "
        
        $("#comments-message").focus()
      
      $scope.scratch = scratch
      $scope.session = session
            
      
    deactivate: ($scope, el, attrs) ->
      
      @enabled = false
      @new_events = 0
      
    activate: ($scope, el, attrs) ->
      
      @badge_class_prefix = "badge-important"
      @enabled = true
      @new_events = 0
      @badge = null
]
