nconf = require("nconf")
request = require("request")

module.exports.middleware = (options = {}) ->
  (req, res, next) ->
    fetchSession = (sessid) ->
      return createSession() unless sessid
      
      request nconf.get("url:api") + "/sessions/#{sessid}", (err, response, body) ->
        if err or response.statusCode >= 400 then createSession()
        else finalize(body)
      
    createSession = ->
      request.post nconf.get("url:api") + "/sessions", (err, response, body) ->
        if err or response.statusCode >= 400 then next("Error creating session: #{err or response}")
        else finalize(body)
      
    finalize = (body) ->
      try
        session = JSON.parse(body)
      catch e
        return next("Error parsing session JSON")
      
      res.local("session", session)
      next()
    
    if sessid = req.cookies.plnk_session then fetchSession(sessid)
    else createSession()
