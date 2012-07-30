#= require ../vendor/angular

#= require ../services/modes

EditSession = require("ace/edit_session").EditSession
UndoManager = require("ace/undomanager").UndoManager


module = angular.module("plunker.ace", ["plunker.modes"])

module.directive "plunkerSession", ["modes", (modes) ->
  restrict: "E"
  require: "?ngModel"
  template: """
    <div style="display: none" ng-model="file.content"></div>
  """
  replace: true
  link: ($scope, el, attrs, ngModel) ->
    file = $scope.file
    
    session = new EditSession(file.content or "")
    session.setTabSize(2)
    session.setUseSoftTabs(true)
    session.setUndoManager(new UndoManager())
    session.setMode(mode.source) if mode = modes.findByFilename(file.filename)
    
    ngModel.$render = ->
      session.setValue(ngModel.$viewValue or "")
    
    read = -> ngModel.$setViewValue(session.getValue())
    session.on 'change', -> $scope.$apply(read)
    
    read()
    
    $scope.$on "$destroy", ->
      #console.log "$destroy", arguments...
      # How do I destroy the session?
      
    $scope.$watch "file.filename", (filename) ->
      session.setMode(mode.source) if mode = modes.findByFilename(file.filename)
    
    $scope.$watch "history.last()", (active) ->
      if active == file
        $scope.ace.setSession(session)
        $scope.ace.focus()
] 

module.directive "plunkerAce", ["modes", (modes) ->
  restrict: "E"
  template: """
    <div class="editor-canvas">
      <plunker-session ng-repeat="(filename, file) in validFiles(plunk.files)"></plunker-session>
    </div>
  """
  replace: true
  link: ($scope, el, attrs, ngModel) ->
    $scope.ace = ace.edit(el[0])
    
    
    $scope.$on "layout:resize", ->
      $scope.ace.resize()
]