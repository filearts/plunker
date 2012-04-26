LRU = require("lru-cache")
nconf = require("nconf")
request = require("request")
express = require("express")
_ = require("underscore")._

module.exports = app = express.createServer()

genid = (len = 16, prefix = "", keyspace = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789") ->
  prefix += keyspace.charAt(Math.floor(Math.random() * keyspace.length)) while len-- > 0
  prefix
  
users = new LRU()
tokens = new LRU(1000)



app.configure ->
  app.use require("./middleware/json").middleware()
  app.use express.cookieParser()

app.get "/auth", (req, res, next) ->
  if req.cookies.plnkr_token
    if (token = tokens.get(req.cookies.plnkr_token)) and (user = users.get(token.user_key))
      return res.json _.extend {}, token,
        user: user
    else res.clearCookie("plnkr_token")
  
  res.json { message: "Not found" }, 404
  
app.del "/auth", (req, res, next) ->
  tokens.del(req.cookies.plnkr_token)
  res.clearCookie("plnkr_token", path: app.path or "/")
  res.send(204)

app.get "/auths/github", (req, res, next) ->
  
  return res.next(new require("./errors").MissingArgument("token")) unless req.query.token
  
  request.get "https://api.github.com/user?access_token=#{req.query.token}", (err, response, body) ->
    return res.next(new require("./errors").Error(err)) if err
    
    try
      body = JSON.parse(body)
    catch e
      return res.next(new require("./errors").InvalidJSON)
    
    return res.next(new require("./errors").Unauthorized(body)) if response.status >= 400
    
    # Create user if not exists
    user_key = "github:#{body.id}"
    
    unless user = users.get(user_key)
      user = body
      users.set(user_key, user)
    
    # Create a new authorization
    token =
      id: "tok-#{genid()}"
      user_key: user_key
      service: "github"
      service_token: req.query.token
      
    tokens.set(token.id, token)
    
    json = _.extend {}, token,
      user: user
    
    res.cookie "plnkr_token", token.id, 
      maxAge: 60 * 60 * 24 * 7 # One week
      path: app.route or "/"
    res.json json, 201

