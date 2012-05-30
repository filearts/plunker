nconf = require("nconf")
request = require("request")
mime = require("mime")
express = require("express")
url = require("url")
querystring = require("querystring")
_ = require("underscore")._

apiErrors = require("./errors")

module.exports = app = express.createServer()

genid = (len = 16, prefix = "", keyspace = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789") ->
  prefix += keyspace.charAt(Math.floor(Math.random() * keyspace.length)) while len-- > 0
  prefix


mongoose = require("../../lib/stores/mongoose")


app.configure ->
  app.use require("./middleware/cors").middleware()
  app.use require("./middleware/json").middleware()
  app.use require("./middleware/session").middleware(sessions: mongoose.model("Session"))
    
  app.use app.router
  
  app.use (err, req, res, next) ->
    json = if err.toJSON? then err.toJSON() else
      message: err.message or "Unknown error"
      code: err.code or 500
    
    res.json(json, json.code)
    
    throw err
    
  app.set "jsonp callback", true

###
# RESTful sessions
###

Session = mongoose.model("Session")

createSession = (token, user, cb) ->
  session = new Session
    
  session.user = user if user
  
  session.save (err) -> cb(err, session)

# Convenience endpoint to get the current session or create a new one
app.get "/session", (req, res, next) ->
  res.header "Cache-Control", "no-cache"
  
  if req.session then res.redirect("#{req.session.url}?#{url.parse(req.url).query}")
  else
    createSession null, null, (err, session) ->
      if err then next(err)
      else res.redirect("#{session.url}?#{url.parse(req.url).query}")


app.post "/sessions", (req, res, next) ->
  createSession null, null, (err, session) ->
    if err then next(err)
    else res.json(session, 201)

app.get "/sessions/:id", (req, res, next) ->
  Session.findById(req.params.id).populate("user").run (err, session) ->
    if err then next(err)
    else unless session then next(new apiErrors.NotFound)
    else
      unless session.user then res.json(session.toJSON())
      else User.findById session.user, (err, user) ->
        if err then next(err)
        else res.json(_.extend(session, user: user.toJSON()))

app.post "/users", (req, res, next) ->
  unless token = req.param("token") then return next(new apiErrors.MissingArgument("token"))
  unless service = req.param("service") then return next(new apiErrors.MissingArgument("service"))
  
  unless service is "github" then return next(new apiErrors.NotFound)
  
  # I know this is a redundant check
  if service is "github" then request.get "https://api.github.com/user?access_token=#{token}", (err, response, body) ->
    return next(new apiErrors.Error(err)) if err
    return next(new apiErrors.PermissionDenied) if response.status >= 400

    try
      body = JSON.parse(body)
    catch e
      return next(new apiErrors.ParseError)

    # Create a new authorization
    upgradeSession = (err, user) ->
      if err then next(err)
      else sessions.get sessid, (err, session) ->
        if err then next(err)
        else sessions.set req.param("id"), _.extend(session, {user: user.id, token: token}), (err) ->
          if err then next(err)
          else res.json(_.extend(session, user: user), 201)
          
    Auth
      .findOne({service: "github", service_id: body.id})
      .populate("user")
      .run (err, auth) ->
        if err then next(err)
        else unless auth.user
          user = new User
            login: body.login
            gravatar_id: body.gravatar_id
          
          user.auths.push(auth)
          user.save (err) ->
            upgradeSession(err, user)
        else upgradeSession(null, user)


app.del "/sessions/:id/upgrade", (req, res, next) ->
  Session.findById req.params.id, (err, session) ->
    if err then next(err)
    else unless session and session.user then next(new apiErrors.NotFound)
    else
      delete session.user
      
      sessions.set session.id, session, (err) ->
        if err then next(err)
        else res.json(session)

app.post "/sessions/:id/upgrade", (req, res, next) ->
  unless token = req.param("token") then next(new apiErrors.MissingArgument("token"))
  else
    sessid = req.param("id")
    
    request.get "https://api.github.com/user?access_token=#{token}", (err, response, body) ->
      return next(new apiErrors.Error(err)) if err
      return next(new apiErrors.PermissionDenied) if response.status >= 400
  
      try
        body = JSON.parse(body)
      catch e
        return next(new apiErrors.ParseError)
  
      # Create a new authorization
      upgradeSession = (err, user) ->
        if err then next(err)
        else sessions.get sessid, (err, session) ->
          if err then next(err)
          else sessions.set req.param("id"), _.extend(session, {user: user.id, token: token}), (err) ->
            if err then next(err)
            else res.json(_.extend(session, user: user), 201)
            
      Auth
        .findOne({service: "github", service_id: body.id})
        .populate("user")
        .run (err, auth) ->
          if err then next(err)
          else unless auth.user
            user = new User
              login: body.login
              gravatar_id: body.gravatar_id
            
            user.auths.push(auth)
            user.save (err) ->
              upgradeSession(err, user)
          else upgradeSession(null, user)



###
# Plunks
###

async = require("async")

waterfall = (steps, context = {}) ->
  (args..., finish) ->
    stream = _.map steps, (step) -> _.bind(step, context) # Bind to context
    stream.unshift (next) -> next(null, args...) # Add a starter
    
    async.waterfall(stream, finish)


# List plunks
app.get "/plunks", (req, res, next) ->
  pp = Math.max(1, parseInt(req.param("pp", "12"), 10))
  start = Math.max(0, parseInt(req.param("p", "1"), 10) - 1) * pp
  end = start + pp
  
  preparer = waterfall require("./chains/plunks/prepare"), user: req.user, users: users, session: req.session
  iterator = ([id, plunk], next) -> preparer(id, plunk, next)
  
  plunks.list start, end, (err, list) ->
    if err then next(err)
    else async.map list, iterator, (err, list) ->
      if err then next(err)
      else res.json(list, 200)
  
# Create plunk
app.post "/plunks", (req, res, next) ->
  creater = waterfall require("./chains/plunks/create"), user: req.user, plunks: plunks, session: req.session, sessions: sessions
  preparer = waterfall require("./chains/plunks/prepare"), user: req.user, users: users, session: req.session
  responder = waterfall [creater, preparer]
  
  responder req.body, (err, plunk) ->
    if err then next(err)
    else res.json(plunk, 201)

# Read plunk
app.get "/plunks/:id", (req, res, next) ->
  fetcher = waterfall require("./chains/plunks/fetch"), plunks: plunks
  preparer = waterfall require("./chains/plunks/prepare"), user: req.user, users: users, session: req.session
  responder = waterfall [fetcher, preparer]
  
  responder req.params.id, (err, plunks) ->
    if err then next(err)
    else res.json(plunks, 200)

# Delete plunk
app.del "/plunks/:id", (req, res, next) ->
  plunks.get req.params.id, (err, plunk) ->
    if err then next(err)
    else unless plunk then next(new apiErrors.NotFound)
    else unless (req.user and plunk.user == req.user.id) or (req.session and req.session.tokens[req.params.id] == plunk.token) then next(new apiErrors.PermissionDenied)
    else plunks.del req.params.id, (err) ->
      if err then next(err)
      else res.send(204)

app.all "*", (req, res, next) ->
  next new apiErrors.NotFound