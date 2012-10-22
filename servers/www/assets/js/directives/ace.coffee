#= require ../services/modes

EditSession = require("ace/edit_session").EditSession
UndoManager = require("ace/undomanager").UndoManager


module = angular.module("plunker.ace", ["plunker.modes"])

module.directive "plunkerSession", ["$rootScope", "$timeout", "modes", ($rootScope, $timeout, modes) ->
  restrict: "E"
  require: "?ngModel"
  template: """
    <div style="display: none" ng-model="buffer.content"></div>
  """
  replace: true
  link: ($scope, el, attrs, ngModel) ->
    buffer = $scope.buffer
    
    session = new EditSession(buffer.content or "")
    session.setTabSize(2)
    session.setUseSoftTabs(true)
    session.setUndoManager(new UndoManager())
    session.setMode(mode.source) if mode = modes.findByFilename(buffer.filename)
    
    ngModel.$render = ->
      session.setValue(ngModel.$viewValue or "")
    
    read = -> ngModel.$setViewValue(session.getValue())
    session.on 'change', ->
      if $scope.$$phase then read()
      else $scope.$apply(read)
    
    session.on "changeAnnotation", -> $scope.$apply ->
      errors = []
      for linenum, notes of session.getAnnotations()
        for note in notes
          if note.lint then errors.push
            message: note.text
            evidence: note.lint.evidence
            col: note.column
            line: note.row
            type: note.type
          else errors.push
            message: note.text
            col: note.column
            line: note.row
            type: note.type
      
      buffer.annotations = errors
    
    read()
    
    $scope.buffer.session = session
    
    $scope.$on "$destroy", ->
      $timeout -> $rootScope.$broadcast "buffer:remove", $scope.buffer
    
    $scope.$watch "buffer.content", (content, old_content) ->
      $rootScope.$broadcast "buffer:change:content", $scope.buffer, content, old_content
    
    $scope.$watch "buffer.filename", (filename, old_filename) ->
      session.setMode(mode.source) if mode = modes.findByFilename(buffer.filename)
      $rootScope.$broadcast "buffer:change:filename", $scope.buffer, filename, old_filename
    
    $scope.$watch "scratch.buffers.active()", (active) ->
      if active == buffer
        $scope.ace.setSession(session)
        $scope.ace.focus()
    
    $rootScope.$broadcast "buffer:add", $scope.buffer
] 

module.directive "plunkerAce", ["$rootScope", "modes", "scratch", ($rootScope, modes, scratch) ->
  restrict: "E"
  template: """
    <div class="editor-canvas">
      <plunker-session ng-repeat="buffer in scratch.buffers.queue"></plunker-session>
    </div>
  """
  replace: true
  link: ($scope, el, attrs, ngModel) ->
    $scope.ace = ace.edit(el[0])
  
    $scope.ace.commands.addCommand
      name: "saveFile"
      bindKey:
        win: "Ctrl-S"
        mac: "Command-S"
      exec: (editor) -> scratch.save()
    
    $rootScope.$on "layout:resize", ->
      $scope.ace.resize()
]