coffee = require("coffee-script")
less = require("less")
jade = require("jade")
express = require("express")
gzippo = require("gzippo")
assets = require("connect-assets")
nconf = require("nconf")
request = require("request")

module.exports = app = express.createServer()

apiUrl = nconf.get("url:api")


###s
# Configure the server
###

app.use assets(src: "#{__dirname}/assets", minifyBuilds: true)
app.use express.static("#{__dirname}/assets")
app.use require("./middleware/expose").middleware
  "url": nconf.get("url")
  "package": require("./package")
app.use express.bodyParser()

app.use app.router

app.use express.logger()



app.set "views", "#{__dirname}/views"
app.set "view engine", "jade"
app.set "view options", layout: false

  
app.post "/", (req, res, next) ->
  res.set "X-XSS-Protection", 0
  
  if req.body.files
    for filename, file of req.body.files
      if typeof file is "string"
        req.body.files[filename] =
          filename: filename
          content: file
      req.body.files[filename].filename ||= filename
  
  res.locals.plunk = req.body
  res.render "embed"

app.get "/:id", (req, res, next) ->
  res.locals.plunk = ""
  res.render "embed"
