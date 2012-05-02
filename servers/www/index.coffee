coffee = require("coffee-script")
less = require("less")
jade = require("jade")
express = require("express")
gzippo = require("gzippo")
assets = require("connect-assets")
nconf = require("nconf")
authom = require("authom")

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
    res.local("package", require("../../package"))
    res.local("url", nconf.get("url"))
    next()

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