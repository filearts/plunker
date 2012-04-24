express = require("express")
less = require("less")
jade = require("jade")
assets = require("connect-assets")
nconf = require("nconf")

module.exports = app = express.createServer()

app.get "/", (req, res) ->
  res.send("WWW Server")