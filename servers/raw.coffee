express = require("express")

module.exports = app = express.createServer()

app.get "/", (req, res) ->
  res.send("RAW Server")