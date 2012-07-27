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
    
    $scope.layout = layout = $(el).layout
      defaults:
        spacing_open: 4
        spacing_closed: 8
      center:
        minSize: 100
      south:
        initClosed: true
      east:
        #spacing_closed: 28
        #initClosed: true
        size: Math.max(0, ($("body").width() - 160) / 2)
        #togglerLength_closed: 60
        #togglerAlign_closed: "top"
        #togglerContent_closed: togglers
      west:
        initClosed: false
        size: 160
        minSize: 160
        maxSize: 320
      onresize: ->
        $scope.$apply ->
          $scope.layout.state = layout.state
          $scope.$broadcast "layout:resize"
      maskContents: true