nconf = require("nconf")

module.exports.middleware = (config = {}) ->
  (req, res, next) ->
    if req.query.sessid then sessid = req.query.sessid
    else if auth = req.header("Authorization") then [header, sessid] = auth.match(/^token (\S+)$/i)

    if sessid and sessid.length then config.sessions.findById(sessid).populate("user").exec (err, session) ->
      return next(err) if err
      return next() unless session
      return next() if Date.now() - session.last_access.valueOf() > nconf.get("session:max_age")
      session.last_access = new Date
      session.save -> # Don't wait for the response
      
      req.session = session
      req.user = session.user if session.user

      next()
    else next()