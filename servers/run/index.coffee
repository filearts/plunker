express = require("express")
nconf = require("nconf")
_ = require("underscore")._
validator = require("json-schema")
mime = require("mime")
url = require("url")

module.exports = app = express.createServer()

runUrl = nconf.get("url:run")

genid = (len = 16, prefix = "", keyspace = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789") ->
  prefix += keyspace.charAt(Math.floor(Math.random() * keyspace.length)) while len-- > 0
  prefix


app.configure ->
  app.use require("./middleware/cors").middleware()
  app.use require("./middleware/json").middleware()
  
  app.set "views", "#{__dirname}/views"
  app.set "view engine", "jade"
  app.set "view options", layout: false

LRU = require("lru-cache")
previews = LRU(512)

app.post "/", (req, res, next) ->
  json = req.body
  schema = require("./schema/previews/create")
  {valid, errors} = validator.validate(json, schema)
  
  # Despite its awesomeness, validator does not support disallow or additionalProperties; we need to check plunk.files size
  if json.files and _.isEmpty(json.files)
    valid = false
    errors.push
      attribute: "minProperties"
      property: "files"
      message: "A minimum of one file is required"
  
  unless valid then next(new Error("Invalid json: #{errors}"))
  else
    id = genid() # Don't care about id clashes. They are disposable anyway
    json.run_url = "#{runUrl}/#{id}/"

    _.each json.files, (file, filename) ->
      json.files[filename] =
        filename: filename
        content: file.content
        mime: mime.lookup(filename, "text/plain")
        run_url: json.run_url + filename

    
    previews.set(id, json)
    
    res.json(json, 201)


app.get "/:id/*", (req, res, next) ->
  unless plunk = previews.get(req.params.id) then res.send(404) # TODO: Better error page
  else
    req_url = url.parse(req.url)
    
    unless req.params[0] or /\/$/.test(req_url.pathname)
      req_url.pathname += "/"
      return res.redirect(url.format(req_url), 301)
  
    # TODO: Determine if a special plunk 'landing' page should be served and serve it
    filename = req.params[0] or "index.html"
    file = plunk.files[filename]
    
    if file then res.send(file.content, {"Content-Type": if req.accepts(file.mime) then file.mime else "text/plain"})
    else if filename then res.send(404)
    else
      res.local "plunk", plunk
      res.render "directory"

app.get "*", (req, res) ->
  res.send("Preview does not exist or has expired.", 404)