express = require("express")
request = require("request")
nconf = require("nconf")
url = require("url")

module.exports = app = express.createServer()

app.configure ->
  app.set "views", "#{__dirname}/views"
  app.set "view engine", "jade"
  app.set "view options", layout: false


apiUrl = nconf.get("url:api")

app.get "/:id/:filename?", (req, res, next) ->
  req_url = url.parse(req.url)
  unless req.params.filename or /\/$/.test(req_url.pathname)
    req_url.pathname += "/"
    return res.redirect(url.format(req_url), 301)
  
  request.get "#{apiUrl}/plunks/#{req.params.id}", (err, response, body) ->
    return res.send(500) if err
    return res.send(response.statusCode) if response.statusCode >= 400
    
    try
      plunk = JSON.parse(body)
    catch e
      return res.send(500)
    
    unless plunk then res.send(404) # TODO: Better error page
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