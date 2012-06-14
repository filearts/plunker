#= require ../vendor/jquery
#= require ../vendor/underscore
#= require ../vendor/backbone
#= require ../vendor/handlebars
#= require ../vendor/ace/ace

#= require ../lib/panel

((plunker) ->
  
  class Filename extends Backbone.View
    tagName: "li"
    className: "file"

    template: Handlebars.compile """
      <a href="#\{{slugify filename}}">
        {{filename}}
      </a>
    """


    events:
      "click":    (e) -> plunker.mediator.trigger "intent:file:activate", @model.get("filename")
      "dblclick": (e) -> plunker.mediator.trigger "intent:file:rename", @model.get("filename")
    
    initialize: ->
      self = @
      
      @model.on "remove", ->
        self.model.off "change:filename", self.render
        self.model.off "change:content", self.onChangeContent
      
      @model.on "change:active change:filename", @render
    
    render: =>
      @$el.html @template
        filename: @model.get("filename")
        
      if @model.get("active") then @$el.addClass("active")
      else @$el.removeClass("active")
      
      @
  
  
  class plunker.Sidebar extends plunker.Panel
    template: Handlebars.compile """
      <ul class="nav nav-list">
        <li class="nav-header">
          Files
        </li>
      </ul>
    """
    
    initialize: ->
      self = @
      @views = {}


      @render()

      @model.buffers.on "reset", @onResetBuffers
      @model.buffers.on "add", @onAddBuffer
      @model.buffers.on "remove", @onRemoveBuffer
      
    viewModel: -> {}
    
    onAddBuffer: (buffer) =>
      self = @
      view = new Filename(model: buffer)
      self.views[buffer.cid] = view
      self.$(".nav-list").append view.render().$el
    
    onRemoveBuffer: (buffer) =>
      self = @
      self.views[buffer.cid].remove()
      delete self.views[buffer.cid]
      
      plunker.mediator.trigger "intent:file:activate", self.model.last()
      
    onResetBuffers: (coll) =>
      self = @
      _.each @views, (view) -> self.onRemoveBuffer(view.model)
      coll.each(@onAddBuffer)

    render: =>
      @$el.html @template(@viewModel())
      @onResetBuffers(@model.buffers)
      @
            
)(@plunker or @plunker = {})