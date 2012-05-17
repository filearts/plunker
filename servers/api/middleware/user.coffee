module.exports.middleware = (config = {}) ->
  (req, res, next) ->
    unless req.session and req.session.user then next()
    else config.users.get req.session.user, (err, user) ->
      return next(err) if err
      
      unless user
        delete req.user
        delete req.session.user
      else req.user = user
      
      next()