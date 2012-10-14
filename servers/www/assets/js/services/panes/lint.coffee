#= require ../../services/panels
#= require ../../services/scratch

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
      
        angular.forEach errors, (error) ->
          if error
            {line, message, evidence, character} = error
            $li = $("<li></li>").addClass("alert").appendTo($errors)
            if error.type is "error" then $li.addClass("alert-error")
            else $li.addClass("alert-info")
            $error = $("<p></p>").appendTo($li)
            $line = $("<a>Line #{line}</a>")
              .attr("href", "javascript:void(0)")
              .attr("data-line", line)
              .attr("data-char", character)
              .addClass("lineno")
              .appendTo($error)
            if evidence
              $error.append(":&nbsp;")
              $code = $("<code>#{evidence}</code>").appendTo($error)
            $reason = $("<p>#{message}</p>").appendTo($li) if message
        
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
    template: """
      <div id="panel-lint" ng-switch on="state">
        <h4>Code linting:</h4>
        <p ng-switch-when="valid" class="alert alert-success">
          No errors
        </p>
        <plunker-lint-report errors="errors" ng-switch-when="invalid"></plunker-lint-report>
      </div>
    """
          
    link: ($scope, el, attrs) ->
      self = @
      
      $scope.state = "valid"

      $scope.scratch = scratch
      $scope.$watch "scratch.buffers.active().annotations", (errors) ->
        if errors and errors.length
          $scope.state = "invalid"
          $scope.errors = errors
          
          self.badge =
            class: "badge badge-important"
            title: "Your code has some errors"
            value: errors.length     
            
        else
          $scope.state = "valid"
          self.badge = null
      
    deactivate: ($scope, el, attrs) ->
      @active = false
      
    activate: ($scope, el, attrs) ->
      @active = true
    
]
