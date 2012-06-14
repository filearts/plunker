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
        
      plunker.mediator.on "intent:file:activate", @onIntentActivate
        
    onIntentActivate: (filename) =>
      if buffer = @model.buffers.get(filename)
        @ace.setSession buffer.session
        @ace.focus()
        
        plunker.mediator.trigger "file:activate", filename
      
)(@plunker or @plunker = {})