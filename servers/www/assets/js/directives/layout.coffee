#= require ../vendor/jquery.ui.custom
#= require ../vendor/jquery.layout

#= require_tree ../services/panes
#= require ../services/panels

module = angular.module("plunker.layout", ["plunker.panels"])

module.directive "plunkerLayout", ["$rootScope", "$location", "$timeout", "panels", ($rootScope, $location, $timeout, panels) ->
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
          east: # Multipane
            spacing_open: 4
            spacing_closed: 0
            size: "50%"
            onclose: ->
              if angularClose then panels.active = null
              else $scope.$apply -> panels.active = null
            onresize: (pane, $el, state) ->
              panels.active.size = state.size
          center: # Editor
            minSize: "20%"
            size: "50%"

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
        $timeout ->
          $scope.layout.state = layout.state
          $rootScope.$broadcast "layout:resize"
        , 100
          
    innerLayout = layout.center.child
    innerLayout.resizers.east.mousedown -> innerLayout.showMasks("east")
    innerLayout.resizers.east.mouseup -> innerLayout.hideMasks("east")
    
    $scope.$watch "layout.center.child.state.east.isClosed", (closed) ->
      if closed then $
    
    angularClose = false
    
    panels.openPanel = (panel) ->
      search = $location.search()
      
      panels.active = panel
      layout.center.child.sizePane("east", panel.size or "50%")
      layout.center.child.open("east")
      search.p = panel.name
        
      $location.search(search).replace()
      
    panels.closePanel = (panel) ->
      search = $location.search()
      
      angularClose = true
      layout.center.child.close("east")
      angularClose = false
      delete panels.active
      delete search.p
        
      $location.search(search).replace()
    
    panels.togglePanel = (panel) ->
      if panels.active == panel then panels.closePanel(panel)
      else panels.openPanel(panel)
    
    $scope.togglePanel = panels.togglePanel
    
    $scope.$watch "panels.active.hidden", (hidden) ->
      if hidden
        panels.reopen = panels.active
        panels.closePanel(panels.active)
    
    $scope.$watch "panels.reopen.hidden", (hidden) ->
      unless hidden
        panels.openPanel(panels.reopen) if panels.reopen
        delete panels.reopen

    if active = $location.search().p
      matched = false
      for panel in panels
        if panel.name == active and not panels.active != panel
          panels.openPanel(panel)
          matched = true
          break
      unless matched
        search = $location.search()
        delete search.p
        $location.search(search).replace()
    else
      panels.togglePanel()
]