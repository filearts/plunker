((plunker) ->
  
  plunker.router = new class extends Backbone.Router
    initialize: ->
      self = @
      
      @urls = {}
      @map api: "#{@url()}/api"
      
      if _.isArray(plunker.routes)
        @route.apply @, route for route in plunker.routes
      
      plunker.routes = 
        push: -> self.route.apply(self, arguments)
    
    map: (urls = {}) -> _.extend(@urls, urls)
    
    url: (type) -> @urls[type] or "#{location.protocol}//#{location.host}"
  
      
)(@plunker or @plunker = {})