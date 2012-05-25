express = require("express")
request = require("request")
nconf = require("nconf")

module.exports = app = express.createServer()

app.configure ->
  app.set "views", "#{__dirname}/views"
  app.set "view engine", "jade"
  app.set "view options", layout: false


app.get "/:id/:filename?", (req, res, next) ->
  request.get nconf.get("url:api") + "/plunks/#{req.params.id}", (err, response, body) ->
    return next(err) if err
    return next(new Error("Not found")) if response.statusCode >= 400
    
    try
      plunk = JSON.parse(body)
    catch e
      return next(new Error("Invalid plunk"))
    
    unless plunk then res.send("No such plunk", 404) # TODO: Better error page
    else
      # TODO: Determine if a special plunk 'landing' page should be served and serve it
      filename = req.params.filename or "index.html"
      file = plunk.files[filename]
      
      if file then res.send(file.content, {"Content-Type": if req.accepts(file.mime) then file.mime else "text/plain"})
      else
        res.local "plunk", plunk
        res.render "directory"

app.get "/:id", (req, res) -> res.redirect("/#{req.params.id}/", 301)

app.get "*", (req, res) ->
  res.send("Whoever gave you this link has sent you to the wrong place.", 404)