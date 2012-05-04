module.exports.middleware = (config = {}) ->
  (req, res, next) ->
    if req.auth then config.users.get req.auth.user_key, (err, user) ->
      return next(err) if err
      unless user
        delete req.auth
        delete req.user
      else
        req.user = user
        req.user.id = req.auth.user_key
      next()
    else next()