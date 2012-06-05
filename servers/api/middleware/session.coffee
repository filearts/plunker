module.exports.middleware = (config = {}) ->
  (req, res, next) ->
    if req.query.sessid then sessid = req.query.sessid
    else if auth = req.header("Authorization") then [header, sessid] = auth.match(/^token (\S+)$/i)

    if sessid and sessid.length then config.sessions.findById(sessid).populate("user").run (err, session) ->
      return next(err) if err
      return next() unless session
      
      req.session = session
      req.user = session.user if session.user

      next()
    else next()