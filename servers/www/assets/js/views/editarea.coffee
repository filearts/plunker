#= require ../vendor/jquery
#= require ../vendor/underscore
#= require ../vendor/backbone
#= require ../vendor/handlebars

#= require ../lib/panel

((plunker) ->
  
  class plunker.Editarea extends plunker.Panel
    className: "editor-canvas"
    initialize: ->
      @ace = ace.edit(@el)
      
      self = @
      
      @on "attached", (layout) ->
        layout.on "resize", -> self.ace.resize()
      
      plunker.mediator.on "file:activate", (filename) ->
        if buffer = self.model.buffers.get(filename)
          self.ace.setSession(buffer.session)
          self.ace.focus()
        

      
)(@plunker or @plunker = {})