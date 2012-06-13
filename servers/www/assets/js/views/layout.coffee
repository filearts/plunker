#= require ../vendor/jquery
#= require ../vendor/underscore
#= require ../vendor/backbone
#= require ../vendor/handlebars

#= require ../vendor/jquery.ui.custom
#= require ../vendor/jquery.layout

((plunker) ->
  
  class plunker.BorderLayout extends Backbone.View
    initialize: (options) ->
      self = @
            
      @layout = @$el.layout
        defaults:
          spacing_open: 4
          spacing_closed: 8
        center:
          minSize: 100
        south:
          initClosed: true
        east:
          initClosed: true
        west:
          initClosed: true
          size: 160
          minSize: 160
          maxSize: 320
        onresize: -> self.trigger "resize", arguments...
    
    attachPanel: (region, panelView, operation = "html") ->
      $panel = @$(".ui-layout-#{region}")
      
      if $panel.size()
        $panel[operation](panelView.$el)
        panelView.trigger "attached", @
      
      @
      
)(@plunker or @plunker = {})