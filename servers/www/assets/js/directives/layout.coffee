#= require ../vendor/jquery
#= require ../vendor/jquery.ui.custom
#= require ../vendor/jquery.layout
#= require ../vendor/angular

#= require_tree ../services/panes
#= require ../services/panels

module = angular.module("plunker.layout", ["plunker.panels"])

module.directive "plunkerLayout", ["panels", (panels) ->
  restrict: "A"
  link: ($scope, el, attrs) ->
        
    $scope.panels = panels

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
              if angularClose then panels.active = null
              else $scope.$apply -> panels.active = null
            onresize: (pane, $el, state) ->
              panels.active.size = state.size

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
          
    innerLayout = layout.center.child
    innerLayout.resizers.east.mousedown -> innerLayout.showMasks("east")
    innerLayout.resizers.east.mouseup -> innerLayout.hideMasks("east")
    
    $scope.$watch "layout.center.child.state.east.isClosed", (closed) ->
      if closed then $
    
    angularClose = false
    
    $scope.togglePanel = (panel) ->
      if panels.active == panel
        angularClose = true
        layout.center.child.close("east")
        angularClose = false
        delete panels.active
      else
        panels.active = panel
        layout.center.child.sizePane("east", panel.size or "50%")
        layout.center.child.open("east")
          
    $scope.togglePanel()
]