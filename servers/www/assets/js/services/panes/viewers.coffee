#= require ../../vendor/jquery
#= require ../../vendor/angular

#= require ../../services/panels
#= require ../../services/session
#= require ../../services/scratch

module = angular.module("plunker.panels")

module.run [ "$timeout", "panels", "session", "scratch", ($timeout, panels, session, scratch) ->
  panels.push new class
    name: "viewers"
    order: 2
    size: 200
    title: "Show/hide the viewers pane"
    icon: "icon-group"
    template: """
      <div class="plnk-compiler">
        <h1>Viewers</h1>
        <ul>
          <li ng-repeat="(public_id, user) in users">
            <img ng-src="http://www.gravatar.com/avatar/{{user.gravatar_id}}?s=18&d=mm" />
            <span class="username">{{user.login}}</span>
          </li>
        </ul>
      </div>
    """
          
    link: ($scope, el, attrs) ->
      self = @
      
      plunkRef = null
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
      
      $scope.$watch "scratch.plunk.id", (id) ->
        if presenceRef
          presenceRef.off "value", handlePresenceValue
          usersRef.off "value", handleUsersValue
          presenceRef.remove()
          
          self.badge = null
        
        return unless id

        plunkRef = new Firebase("http://gamma.firebase.com/filearts/#{id}/")
        usersRef = plunkRef.child("editors")
        presenceRef = usersRef.child(session.public_id)
        
        setOwnPresence(presenceRef)
          
        presenceRef.on "value", handlePresenceValue
        usersRef.on "value", handleUsersValue
      
      $scope.scratch = scratch
      $scope.session = session
            
      
    deactivate: ($scope, el, attrs) ->
      
      @enabled = false
      
    activate: ($scope, el, attrs) ->
      
      @enabled = true
]
