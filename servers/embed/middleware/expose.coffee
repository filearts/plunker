module.exports.middleware = (options = {}) ->
  (req, res, next) ->
    res.locals[key] = value for key, value of options
    next()