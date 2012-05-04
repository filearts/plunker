express = require("express")
request = require("request")

module.exports = app = express.createServer()

{plunks} = require("../../lib/stores")


app.get "/:id/:filename?", (req, res) ->
  plunks.get req.params.id, (err, plunk) ->
    if err then next(err)
    else unless plunk then res.send("No such plunk", 404) # TODO: Better error page
    else
      # TODO: Determine if a special plunk 'landing' page should be served and serve it
      filename = req.params.filename or "index.html"
      file = plunk.files[filename]
      
      unless file then res.send("Plunk exists, but not the file you're looking for", 404) # TODO: Custom error page for when plunk exists but not requested file
      else res.send(file.content, {"Content-Type": if req.accepts(file.mime) then file.mime else "text/plain"})

app.get "/:id", (req, res) -> res.redirect("/#{req.params.id}/", 301)

app.get "*", (req, res) ->
  res.send("Whoever gave you this link has sent you to the wrong place.", 404)