nconf = require("nconf")
request = require("request")

module.exports.middleware = (options = {}) ->
  
  sessions = options.cache
  apiUrl = nconf.get("url:api")
  
  (req, res, next) ->
    fetchSession = (sessid) ->
      return createSession() unless sessid
      
      return finalize(session) if sessions and session = sessions.get(sessid)
        
      request "#{apiUrl}/sessions/#{sessid}", (err, response, body) ->
        if err or response.statusCode >= 400 then createSession()
        else finalize(parse(body))
      
    createSession = ->
      request.post "#{apiUrl}/sessions", (err, response, body) ->
        if err or response.statusCode >= 400 then next("Error creating session: #{err or response}")
        else finalize(parse(body))
    
    parse = (body) ->
      try
        session = JSON.parse(body)
      catch e
        return next("Error parsing session JSON")
      
      sessions.set(sessid, session) if sessions
      
      return session
      
    finalize = (session) ->
      res.local("session", session)
      next()
    
    if sessid = req.cookies.plnk_session then fetchSession(sessid)
    else createSession()
