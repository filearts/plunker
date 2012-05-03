module.exports.middleware = (config = {}) ->
  (req, res, next) ->
    if req.cookies.plnkr_auth then config.auths.get req.cookies.plnkr_auth, (err, auth) ->
      return next(err) if err
      req.auth = auth
      next()
    else next()