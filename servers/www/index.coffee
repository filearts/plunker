coffee = require("coffee-script")
less = require("less")
jade = require("jade")
express = require("express")
gzippo = require("gzippo")
assets = require("connect-assets")
nconf = require("nconf")
authom = require("authom")
request = require("request")

module.exports = app = express.createServer()


###
# Configure oauth
###

github = authom.createServer
  service: "github"
  id: nconf.get("oauth:github:id")
  secret: nconf.get("oauth:github:secret")
  scope: ["gist"]

###s
# Configure the server
###

app.configure ->
  app.use assets(src: "#{__dirname}/assets")
  app.use gzippo.staticGzip("#{__dirname}/static")
  app.use express.cookieParser()
  app.use express.bodyParser()
  app.use (req, res, next) ->
    res.local("sessid", req.cookies.plnk_session or "")
    res.local("package", require("../../package"))
    res.local("url", nconf.get("url"))
    next()
    
  app.use app.router
  
  app.use (err, req, res, next) ->
    json = if err.toJSON? then err.toJSON() else
      message: err.message or "Unknown error"
      code: err.code or 500
    
    res.json(json, json.code)
    
    throw err

  app.set "views", "#{__dirname}/views"
  app.set "view engine", "jade"
  app.set "view options", layout: false


app.get "/auth/:service", authom.app


authom.on "auth", (req, res, auth) ->
  res.render "auth/success", auth: auth


authom.on "error", (req, res, data) ->
  res.status 403
  res.render "auth/error", auth: data



app.get "/", (req, res) ->
  res.render "landing"

app.get "/browse", (req, res) ->
  res.render "browse"


app.get "/:id", (req, res, next) ->
  request.get nconf.get("url:api") + "/plunks/#{req.params.id}", (err, response, body) ->
    return next(err) if err
    return next(new Error("Not found")) if response.statusCode >= 400
    
    try
      body = JSON.parse(body)
    catch e
      return next(new Error("Invalid plunk"))
    
    res.local "plunk", body
    res.render "preview"
  
app.get "*", (req, res) ->
  res.send "Hello, you've reached the end of the internet. I don't know how you got here, or who told you this place exists, but its not somewhere you should be hanging out.", 404