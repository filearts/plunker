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
    "package": require("./package")
    "bootstrap": null
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


app.get "/partials/:partial", (req, res, next) ->
  res.render "partials/#{req.params.partial}"

app.get "/edit/*", (req, res, next) ->
  res.render "editor"
  
app.all "/edit/", (req, res, next) ->
  res.header("Access-Control-Allow-Origin", req.headers.origin or "*")
  res.header("Access-Control-Allow-Methods", "OPTIONS,GET,PUT,POST,DELETE")
  res.header("Access-Control-Allow-Headers", "Authorization, User-Agent, Referer, X-Requested-With, Proxy-Authorization, Proxy-Connection, Accept-Language, Accept-Encoding, Accept-Charset, Connection, Content-Length, Host, Origin, Pragma, Accept-Charset, Cache-Control, Accept, Content-Type")
  res.header("Access-Control-Expose-Headers", "Link")
  res.header("Access-Control-Max-Age", "60")

  if "OPTIONS" == req.method then res.send(200)
  else next()

app.post "/edit/", (req, res, next) ->    
  res.local "bootstrap", req.body or {}
  res.render "editor"

app.all "/edit", (req, res, next) -> res.redirect("/edit/", 302)

app.get "/*", (req, res) ->
  res.render "landing"



app.get "*", (req, res) ->
  res.send "Hello, you've reached the end of the internet. I don't know how you got here, or who told you this place exists, but its not somewhere you should be hanging out.", 404