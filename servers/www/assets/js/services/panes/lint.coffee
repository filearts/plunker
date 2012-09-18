#= require ../../services/panels
#= require ../../services/scratch

#= require ../../vendor/jshint

module = angular.module("plunker.panels")

module.requires.push("plunker.card", "plunker.scratch")

module.directive "plunkerLintReport", [ ->
  restrict: "E"
  scope:
    errors: "="
    
  link: ($scope, el, attrs) ->
    
    $scope.$watch "errors", (errors) ->
      if errors
        $wrap = $("<div></div>")
        $report = $("<div></div>")
          .addClass("jshint-report")
          .appendTo($wrap)
        $errors = $("<ul></ul>").addClass("jshint-errors").appendTo($report)
      
        angular.forEach errors, ({line, reason, evidence, character}) ->
          $li = $("<li></li>").addClass("alert alert-error").appendTo($errors)
          $error = $("<p></p>").appendTo($li)
          $line = $("<a>Line #{line}</a>")
            .attr("href", "javascript:void(0)")
            .attr("data-line", line)
            .attr("data-char", character)
            .addClass("lineno")
            .appendTo($error)
          $error.append(":&nbsp;")
          $code = $("<code>#{evidence}</code>").appendTo($error)
          $reason = $("<p>#{reason}</p>").appendTo($li)
        
        html = $wrap.html()
        $wrap.remove()
        
        el.html(html)
]

module.run [ "$location", "panels", "scratch", ($location, panels, scratch) ->
  panels.push new class
    name: "lint"
    order: 99
    size: 375
    title: "Run a lint check on the active file"
    icon: "icon-check"
    hidden: true
    template: """
      <div id="panel-lint" ng-switch on="state">
        <div ng-switch-when="valid" class="alert alert-success">
          <h4>All clean!</h4>
        </div>
        <div ng-switch-when="invalid">
          <h4>Lint errors:</h4>
          <plunker-lint-report errors="errors"></plunker-lint-report>
        </div>
      </div>
    """
          
    link: ($scope, el, attrs) ->
      self = @
      
      $scope.state = "valid"

      $scope.scratch = scratch
      $scope.$watch "scratch.buffers.active()", (buffer) ->
        self.hidden = !buffer or !buffer.filename.match(/\.js$/)
      
      $scope.$watch "scratch.buffers.active().content", (content) ->
        unless self.hidden
          $scope.state = "linting"
          
          valid = JSHINT content,
            browser: false
            devel: true
          
          unless valid
            $scope.state = "invalid"
            $scope.errors = JSHINT.errors
            
            console.log "JSHINT.errors", JSHINT.errors
            
            self.badge =
              class: "badge badge-important"
              title: "Your code has some errors"
              value: JSHINT.errors.length        
              
          else
            $scope.state = "valid"
            self.badge = null
      
    deactivate: ($scope, el, attrs) ->
      @active = false
      
    activate: ($scope, el, attrs) ->
      @active = true
    
    lint: (filename, content) ->
      
]
