module.exports.middleware = (config = {}) ->
  (req, res, next) ->
    if req.query.sessid then token = req.query.sessid
    else if auth = req.header("Authorization") then [header, token] = auth.match(/^token (\S+)$/i)
    
    if token then config.sessions.get token, (err, session) ->
      return next(err) if err
      
      req.session = session

      next()
    else next()