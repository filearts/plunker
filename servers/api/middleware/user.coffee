module.exports.middleware = (config = {}) ->
  (req, res, next) ->
    if req.auth then config.users.get req.auth.user_key, (err, user) ->
      return next(err) if err
      req.user = user
      unless req.user
        delete req.auth
        delete req.user
      next()
    else next()