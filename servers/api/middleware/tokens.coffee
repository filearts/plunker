_ = require("underscore")._

module.exports.middleware = (config = {}) ->
  (req, res, next) ->
    bucket = (tokens) ->
      tokens = [] unless _.isArray(tokens)
      
      update = ->
        res.cookie "plnkr_tokens", tokens.join(","),
          expires: new Date(Date.now() + 1000 * 60 * 60 * 24 * 7 * 52) # Fifty-two weeks
          domain: config.domain
          path: config.path
      
      add: (token) ->
        tokens.push(token)
        update()
      
      remove: (token) ->
        tokens = _.without(tokens, token)
        update()
      
      has: (token) -> tokens.indexOf(token) >= 0
          
    try
      tokens = if req.cookies.plnkr_tokens then req.cookies.plnkr_tokens.split(",") else []
    catch err
      # Carry on; nothing to see here.
      
    req.tokens = bucket(tokens)
    
    next()
