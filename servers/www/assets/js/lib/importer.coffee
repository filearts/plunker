#= require_tree ./importers

((plunker) ->
  
  plunker.importers ||= []
  
  plunker.import = (source, cb) ->
    index = 0
    success = (json) -> cb(null, json)
    ((error) ->
      if error then cb(error)
      else if current = plunker.importers[index++]
        current(source, success, arguments.callee)
      else
        cb(null, null)
    )()
    @
      
  
)(@plunker or @plunker = {})