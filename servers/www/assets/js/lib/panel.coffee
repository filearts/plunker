#= require ../vendor/jquery
#= require ../vendor/underscore
#= require ../vendor/backbone

((plunker) ->
  
  class plunker.Panel extends Backbone.View
    tagName: "div"
    
    initialize: (options) ->
      throw new Error("No layout") unless options.layout
      @setLayout(options.layout)
      @attachToPanel(options.panel)
      
)(@plunker or @plunker = {})