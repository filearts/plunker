module.exports.middleware = (config = {}) ->
  (req, res, next) ->
    res.header("Cache-Control", "no-cache")
    res.header("Expires", "0")
    
    next()