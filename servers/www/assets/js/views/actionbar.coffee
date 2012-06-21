#= require ../vendor/jquery
#= require ../vendor/underscore
#= require ../vendor/backbone
#= require ../vendor/handlebars

((plunker) ->
  
  class plunker.Actionbar extends Backbone.View
    className: "editor-status"
    template: Handlebars.compile """
      <div class="btn-group">
        <button class="save btn">
          <i class="icon-save" />
          <span class="text">Save</span>
        </button>
      </div>
    """
    
    events:
      "click .save": -> plunker.mediator.trigger "intent:save"
    
    initialize: ->
      self = @
      
      @render = _.throttle(@render, 100)
      @render()
      
    viewModel: ->
      buffers: @model.buffers.toJSON()
      active: @model.get("active")

    render: =>
      @$el.html @template(@viewModel())
      @
      
)(@plunker or @plunker = {})