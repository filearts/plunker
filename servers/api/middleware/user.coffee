module.exports.middleware = (config = {}) ->
  (req, res, next) ->
    unless req.session then next()
    else config.users.get req.session.user, (err, user) ->
      return next(err) if err
      
      unless user
        delete req.session
        delete req.user
      else req.user = user
      
      next()