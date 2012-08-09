coffee = require("coffee-script")
less = require("less")
jade = require("jade")
express = require("express")
gzippo = require("gzippo")
assets = require("connect-assets")
nconf = require("nconf")
authom = require("authom")
request = require("request")
sharejs = require("share")

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
  app.use assets(src: "#{__dirname}/assets", minifyBuilds: true)
  app.use gzippo.staticGzip("#{__dirname}/assets")
  app.use express.cookieParser()
  app.use express.bodyParser()
  app.use require("./middleware/expose").middleware
    "url": nconf.get("url")
    "package": require("../../package")
  app.use require("./middleware/session").middleware()    
  # Start the sharejs server before variable routes
  sharejs.server.attach app,
    db:
      type: "none"
  app.use app.router
  app.use require("./middleware/error").middleware()    


  app.set "views", "#{__dirname}/views"
  app.set "view engine", "jade"
  app.set "view options", layout: false


app.get "/auth/:service", (req, res, next) ->
  req.headers.host = nconf.get("host")
  
  next()

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

app.get "/edit/*", (req, res, next) ->
  res.render "editor"

app.get "/edit", (req, res, next) -> res.redirect("/edit/", 302)

app.get "/:id/:anything?", (req, res, next) ->
  request.get nconf.get("url:api") + "/plunks/#{req.params.id}?sessid=#{req.cookies.plnk_session or ''}", (err, response, body) ->
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