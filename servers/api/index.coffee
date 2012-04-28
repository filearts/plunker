nconf = require("nconf")
request = require("request")
express = require("express")
_ = require("underscore")._

module.exports = app = express.createServer()

genid = (len = 16, prefix = "", keyspace = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789") ->
  prefix += keyspace.charAt(Math.floor(Math.random() * keyspace.length)) while len-- > 0
  prefix


Database = require("./stores/memory").Database

users = new Database("/tmp/users.json")
auths = new Database("/tmp/auths.json")



app.configure ->
  app.use require("./middleware/cors").middleware(credentials: true)
  app.use express.cookieParser()
  app.use express.session(secret: genid())
  app.use require("./middleware/json").middleware()
  app.use require("./middleware/auth").middleware(auths: auths)
  app.use require("./middleware/user").middleware(users: users)

  app.set "jsonp callback", true


###
# Authentication shinanigans
###

app.get "/auth", (req, res, next) ->
  if req.user then return res.json _.defaults req.auth,
    user: req.user

  res.json {}

app.del "/auth", (req, res, next) ->
  auths.del req.cookies.plnkr_token, (err) ->
    return next(err) if err
    res.clearCookie("plnkr_token", path: app.path or "/")
    res.send(204)

app.get "/auths/github", (req, res, next) ->
  return res.next(new require("./errors").MissingArgument("token")) unless req.query.token

  if req.user then return res.json _.defaults req.auth,
    user: req.user

  request.get "https://api.github.com/user?access_token=#{req.query.token}", (err, response, body) ->
    return res.next(new require("./errors").Error(err)) if err

    try
      body = JSON.parse(body)
    catch e
      return res.next(new require("./errors").InvalidJSON)

    return res.next(new require("./errors").Unauthorized(body)) if response.status >= 400

    # Create a new authorization
    createAuth = (err, user) ->
      return res.next(err) if err

      auth =
        id: req.session.id
        user_key: user_key
        service: "github"
        service_token: req.query.token

      auths.set auth.id, auth, (err) ->
        return res.next(err) if err

        json = _.defaults auth,
          user: user

        res.cookie "plnkr_token", auth.id,
          path: if nconf.get("nosubdomains") is true then app.path else "/"
          domain: nconf.get("host")
          expires: new Date(Date.now() - 1)
          httpOnly: true
          
        res.json json, 201

    # Create user if not exists
    user_key = "github:#{body.id}"

    users.get user_key, (err, user) ->
      unless user
        user = body
        users.set user_key, user, createAuth
      else createAuth(null, user)



###
# Plunks
###

app.get "/plunks", (req, res, next) ->