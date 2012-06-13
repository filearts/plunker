#= require ../vendor/jquery
#= require ../vendor/underscore
#= require ../vendor/backbone
#= require ../vendor/handlebars
#= require ../vendor/ace/ace

#= require ../lib/panel

((plunker) ->
  
  class plunker.Editarea extends plunker.Panel
    className: "editor-canvas"
    initialize: ->
      @ace = ace.edit(@el)
      
      self = @
      
      @on "attached", (layout) ->
        layout.on "resize", -> self.ace.resize()
      
)(@plunker or @plunker = {})