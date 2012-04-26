module.exports.middleware = (config = {}) ->
  (req, res, next) ->
    if req.cookies.plnkr_token then config.auths.get req.cookies.plnkr_token, (err, auth) ->
      return next(err) if err
      req.auth = auth
      res.clearCookie("plnkr_token") unless req.auth
      next()
    else next()