express = require("express")
nconf = require("nconf")
_ = require("underscore")._
validator = require("json-schema")
mime = require("mime")
url = require("url")
request = require("request")
path = require("path")

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
apiUrl = nconf.get("url:api")

coffee = require("coffee-script")
livescript = require("LiveScript")
iced = require("iced-coffee-script")
less = require("less")
sass = require("sass")
jade = require("jade")
markdown = require("marked")
stylus = require("stylus")
nib = require("nib")

compilers = 
  sass:
    match: /\.css$/
    ext: ['sass']
    compile: (str, fn) ->
      try
        fn(null, sass.render(str))
      catch err
        fn(err)

  less: 
    match: /\.css$/
    ext: ['less']
    compile: (str, fn) ->
      try
        less.render(str, fn)
      catch err
        fn(err)

  stylus: 
    match: /\.css/
    ext: ['styl']
    compile: (str, fn) ->
      try
        stylus(str)
          .use(nib())
          .import("nib")
          .render(fn)
      catch err
        fn(err)      
  coffeescript: 
    match: /\.js$/
    ext: ['coffee']
    compile: (str, fn) ->
      try
        fn(null, coffee.compile(str, bare: true))
      catch err
        fn(err)
      
  livescript: 
    match: /\.js$/
    ext: ['ls']
    compile: (str, fn) ->
      try
        fn(null, livescript.compile(str))
      catch err
        fn(err)      
      
  icedcoffee: 
    match: /\.js$/
    ext: ['iced']
    compile: (str, fn) ->
      try
        fn(null, iced.compile(str, runtime: "inline"))
      catch err
        fn(err)

  jade: 
    match: /\.html$/
    ext: ['jade']
    compile: (str, fn) ->
      render = jade.compile(str, pretty: true)
      try
        fn(null, render({}))
      catch err
        fn(err)
      
  markdown: 
    match: /\.html$/
    ext: ['md',"markdown"]
    compile: (str, fn) ->
      try
        fn(null, markdown(str))
      catch err
        fn(err)

renderPlunkFile = (req, res, next) ->
  # TODO: Determine if a special plunk 'landing' page should be served and serve it
  plunk = req.plunk
  filename = req.params[0] or "index.html"
  file = plunk.files[filename]
  
  res.header "Cache-Control", "no-cache"
  res.header "Expires", 0
  
  if file then res.send(file.content, {"Content-Type": if req.accepts(file.mime) then file.mime else "text/plain"})
  else if filename
    base = path.basename(filename, path.extname(filename))
    type = mime.lookup(filename) or "text/plain"
    
    for name, compiler of compilers when filename.match(compiler.match)
      for ext in compiler.ext
        if found = plunk.files["#{base}.#{ext}"]
          compiler.compile found.content, (err, compiled) ->
            if err then next(err)
            else res.send(compiled, {"Content-Type": if req.accepts(type) then type else "text/plain"})
          break
    
    res.send(404) unless found
    
  else
    res.local "plunk", plunk
    res.render "directory"
    

app.get "/plunks/:id/*", (req, res, next) ->
  req_url = url.parse(req.url)
  unless req.params[0] or /\/$/.test(req_url.pathname)
    req_url.pathname += "/"
    return res.redirect(url.format(req_url), 301)
  
  request.get "#{apiUrl}/plunks/#{req.params.id}", (err, response, body) ->
    return res.send(500) if err
    return res.send(response.statusCode) if response.statusCode >= 400
    
    try
      req.plunk = JSON.parse(body)
    catch e
      return res.send(500)
    
    unless req.plunk then res.send(404) # TODO: Better error page
    else renderPlunkFile(req, res, next)

app.get "/plunks/:id", (req, res) -> res.redirect("/#{req.params.id}/", 301)

app.post "/:id?", (req, res, next) ->
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
    id = req.params.id or genid() # Don't care about id clashes. They are disposable anyway
    json.id = id
    json.run_url = "#{runUrl}/#{id}/"

    _.each json.files, (file, filename) ->
      json.files[filename] =
        filename: filename
        content: file.content
        mime: mime.lookup(filename, "text/plain")
        run_url: json.run_url + filename

    
    previews.set(id, json)
    
    status = if req.params.id then 200 else 201
    
    res.json(json, status)



app.get "/:id/*", (req, res, next) ->
  unless req.plunk = previews.get(req.params.id) then res.send(404) # TODO: Better error page
  else
    req_url = url.parse(req.url)
    
    unless req.params[0] or /\/$/.test(req_url.pathname)
      req_url.pathname += "/"
      return res.redirect(url.format(req_url), 301)
    
    renderPlunkFile(req, res, next)

app.get "*", (req, res) ->
  res.send("Preview does not exist or has expired.", 404)