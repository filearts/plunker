#= require ../vendor/underscore
#= require ../vendor/page

#= require ../models/plunks

((plunker) ->
  
  class plunker.Router
    constructor: ->
      @urls = {}
      
    start: (options = {}) ->
      page.base(@base) if @base
      page.start(options)
      
    route: (path, callbacks...) -> page(arguments...) if callbacks.length

    map: (urls = {}) -> _.extend(@urls, urls)
    
    url: (type) -> @urls[type] or "#{location.protocol}//#{location.host}"  
      
)(@plunker or @plunker = {})