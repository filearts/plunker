nconf = require("nconf")
request = require("request")

module.exports.middleware = (options = {}) ->
  (req, res, next) ->
    fetchSession = (sessid) ->
      request nconf.get("url:api") + "/sessions/#{sessid}", (err, response, body) ->
        return next("TODO: Internal error") if err
        
        if response.statusCode >= 400 then createSession()
        else finalize(body)
      
    createSession = ->
      request.post nconf.get("url:api") + "/sessions", (err, response, body) ->
        return next("TODO: Internal error") if err
        
        if response.statusCode >= 400 then next("TODO: Internal error")
        else finalize(body)
      
    finalize = (body) ->
      try
        session = JSON.parse(body)
      catch e
        return next("TODO: Internal error")
      
      res.local("session", session)
      next()
    
    if sessid = req.cookies.plnk_session then fetchSession(sessid)
    else createSession()
