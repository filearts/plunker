#= require ../vendor/angular

#= require ../services/modes

EditSession = require("ace/edit_session").EditSession
UndoManager = require("ace/undomanager").UndoManager


module = angular.module("plunker.ace", ["plunker.modes"])

module.directive "plunkerAce", ["modes", (modes) ->
  restrict: "A"
  link: ($scope, el, attrs, ngModel) ->
    $scope.ace = ace.edit(el[0])
    $scope.$on "layout:resize", ->
      $scope.ace.resize()
    
    $scope.$watch "scratch.files", (files) ->
      for filename, file of files then do (filename, file) ->
        unless file.session
          session = new EditSession(file.content or "")
          session.setTabSize(2)
          session.setUseSoftTabs(true)
          session.setUndoManager(new UndoManager())
          session.setMode(modes.findByFilename(file.filename).source)
          
          changing = false
          
          #$scope.$watch file.content, (content) ->
          #  console.log "VALUE", content
          #  changing = true
          #  session.setValue(content)
          #  changing = false
          
          read = -> file.content = session.getValue()
          session.on 'change', -> $scope.$apply(read) unless changing
          
          file.session = session

    $scope.$watch "active", (active) ->
      console.log "active$watch", arguments...
      $scope.ace.setSession(active.session) if active.session
]