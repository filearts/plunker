module.exports.middleware = (config = {}) ->
  (req, res, next) ->
    config.auths.get req.session.id, (err, auth) ->
      return next(err) if err
      req.auth = auth
      next()