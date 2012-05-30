module.exports.middleware = (config = {}) ->
  (req, res, next) ->
    if req.query.sessid then sessid = req.query.sessid
    else if auth = req.header("Authorization") then [header, sessid] = auth.match(/^token (\S+)$/i)
    
    if sessid then config.sessions.findById(sessid).populate("user").run (err, session) ->
      return next(err) if err
      
      req.session = session

      next()
    else next()