module.exports.middleware = (options = {}) ->
  (req, res, next) ->
    res.local(key, value) for key, value of options
    next()