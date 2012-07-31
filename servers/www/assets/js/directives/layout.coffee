#= require ../vendor/jquery
#= require ../vendor/jquery.ui.custom
#= require ../vendor/jquery.layout
#= require ../vendor/angular

module = angular.module("plunker.layout", [])

module.directive "plunkerLayout", ->
  restrict: "A"
  link: ($scope, el, attrs) ->
    
    togglers = """
      <div class="btn-group">
        <div style="background-color: black; border-bottom: 1px solid #333; width:28px; height: 28px;"><i class="icon-ban-circle" /></div>
        <div style="background-color: black; border-bottom: 1px solid #333; width:28px; height: 28px;"><i class="icon-eye-open" /></div>
      </div>
    """
    
    $scope.panes = [
        name: "preview"
        description: "Show/hide the live preview pane"
        icon: "icon-eye-open"
      ,
        name: "compiler"
        description: "Show/hide the live compilation and linting pane"
        icon: "icon-magic"
      ,
        name: "comments"
        description: "Show/hide the comments pane"
        icon: "icon-comments"
      ,
        name: "stream"
        description: "Show/hide the streaming session pane"
        icon: "icon-fire"
    ]

    $scope.layout = layout = $(el).layout
      defaults:
        spacing_open: 4
        spacing_closed: 8
      center: # Editor / Multipane
        minSize: 100
        childOptions:
          maskContents: true
          center: # Editor
            minSize: 100
            size: "50%"
          east: # Multipane
            spacing_open: 4
            spacing_closed: 0
            size: "50%"
            onclose: ->
              if angularClose then $scope.activePane = null
              else $scope.$apply -> $scope.activePane = null
      east: # Multipane buttons
        size: 41 # 40px + 1px border
        closable: false
        resizable: false
        spacing_open: 1
        spacing_closed: 1
      west: # Sidbar
        initClosed: false
        size: 160
        minSize: 160
        maxSize: 320
      onresize: ->
        $scope.$apply ->
          $scope.layout.state = layout.state
          $scope.$broadcast "layout:resize"
    
    $scope.$watch "layout.center.child.state.east.isClosed", (closed) ->
      if closed then $
    
    angularClose = false
    
    $scope.togglePane = (pane) ->
      if $scope.activePane == pane
        angularClose = true
        layout.center.child.close("east")
        angularClose = false
      else
        $scope.activePane = pane
        layout.center.child.open("east")
          
    $scope.togglePane()
