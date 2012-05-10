module.exports.middleware = (config = {}) ->
  (req, res, next) ->
    if req.query.auth? then token = req.query.auth
    else if auth = req.header("Authorization") then [header, token] = auth.match(/^token (\S+)$/i)
    
    if token then config.auths.get token, (err, auth) ->
      return next(err) if err
      req.auth = auth
      next()
    else next()