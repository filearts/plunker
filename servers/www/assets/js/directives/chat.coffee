#= require ../services/session

module = angular.module("plunker.chat", [])

module.directive "plunkerChat", ["$timeout", "session", ($timeout, session) ->
  restrict: "A"
  link: ($scope, el, attrs) ->
    #pane = $scope.panes[4]
    ownStatusRef = null
    editorsRef = null
    
    $scope.viewers = {}
    
    updateOwnStatus = ->
      if ownStatusRef
        ownStatusRef.set session.user or
          login: "Anonymous"
          gravatar_id: "0"
    
    createOwnStatusRef = ->
      if editorsRef
        ownStatusRef.remove() if ownStatusRef
        ownStatusRef = editorsRef.child(session.public_id)
        ownStatusRef.removeOnDisconnect()

        updateOwnStatus()
    
    $scope.$watch "session.public_id", (public_id) -> createOwnStatusRef()
    $scope.$watch "session.user", (user) -> updateOwnStatus()
      
    
    $scope.$watch "plunk.id", (id, old_id) ->
      id ||= $scope.plunk.source?.title or "empty_plunk"
            
      if (id isnt old_id) and ownStatusRef
        ownStatusRef.remove()

      if id
        editorsRef = new Firebase("http://filearts.firebaseio.com/#{id}/editors/")
        editorsRef.on "value", (snapshot) ->
          if val = snapshot.val() then $timeout ->
            $scope.viewers = val
        editorsRef.on "child_added", (snapshot) ->
          if val = snapshot.val() and public_id = snapshot.name() then $timeout ->
            $scope.viewers[public_id] = val
        editorsRef.on "child_removed", (snapshot) ->
          if public_id = snapshot.name() then $timeout ->
            delete $scope.viewers[public_id]
        
        createOwnStatusRef()
]