#= require ../vendor/jquery
#= require ../vendor/underscore
#= require ../vendor/backbone

((plunker) ->
  
  class plunker.Overlay extends Backbone.View
    initialize: (options = {}) ->
      options = _.defaults options,
        enableEvents = []
        disableEvents = []
        
      for event in options.enableEvents
        plunker.mediator.on event, @onEnable
        
      for event in options.disableEvents
        plunker.mediator.on event, @onDisable
    
    onEnable: =>
      @$overlay.remove() if @$overlay
      
    onDisable: =>
      @$overlay.remove() if @$overlay
      @$overlay = $('<div class="plnkr-overlay"></div>').prependTo(@$el)
    
)(@plunker or @plunker = {})