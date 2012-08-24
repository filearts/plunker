coffee = require("coffee-script")
less = require("less")
jade = require("jade")
express = require("express")
gzippo = require("gzippo")
assets = require("connect-assets")
nconf = require("nconf")
request = require("request")

module.exports = app = express.createServer()



###s
# Configure the server
###

app.configure ->
  app.use assets(src: "#{__dirname}/assets", minifyBuilds: true)
  app.use gzippo.staticGzip("#{__dirname}/assets")
  app.use require("./middleware/expose").middleware
    "url": nconf.get("url")
    "package": require("./package")
  # Start the sharejs server before variable routes

  app.set "views", "#{__dirname}/views"
  app.set "view engine", "jade"
  app.set "view options", layout: false

app.get "/:id", (req, res, next) ->
  res.render "embed"