((plunker) ->
  
  plunker.router = new class extends Backbone.Router
    initialize: ->
      self = @
      
      if _.isArray(plunker.routes)
        @route.apply @, route for route in plunker.routes
      
      plunker.routes = 
        push: -> self.route.apply(self, arguments)
  
      
)(@plunker or @plunker = {})