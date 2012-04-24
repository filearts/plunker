((plunker) ->
  
  plunker.router = new class extends Backbone.Router
    initialize: ->
      self = @
      
      if _.isArray(plunker.routes)
        @route.apply @, route for route in plunker.routes
      
      plunker.routes = 
        push: -> self.route.apply(self, arguments)
    
    url: (type) ->
      switch type
        when "api" then "http://plunker.no.de/api/v1"
        else "http:#{location.protocol}//#{location.host}"
  
      
)(@plunker or @plunker = {})