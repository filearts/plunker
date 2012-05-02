nconf = require("nconf")
request = require("request")
mime = require("mime")
express = require("express")
url = require("url")
revalidator = require("revalidator")
_ = require("underscore")._

apiErrors = require("./errors")

module.exports = app = express.createServer()

genid = (len = 16, prefix = "", keyspace = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789") ->
  prefix += keyspace.charAt(Math.floor(Math.random() * keyspace.length)) while len-- > 0
  prefix


Database = require("./stores/memory").Database

users = new Database("/tmp/users.json")
auths = new Database("/tmp/auths.json", {maxLength: 1000}) # TODO: Revisit this arbitrary number
plunks = new Database("/tmp/plunks.json")
expiring = new Database
  maxLength: 1024 * 1024 # 1Mb or so
  lengthCalculator: (item) -> JSON.stringify(item).length



app.configure ->
  app.use require("./middleware/cors").middleware()
  app.use express.cookieParser()
  app.use require("./middleware/json").middleware()
  app.use require("./middleware/auth").middleware(auths: auths)
  app.use require("./middleware/user").middleware(users: users)
  app.use app.router
  app.use (err, req, res, next) ->
    res.json((if err.toJSON? then err.toJSON() else err), err.code or 500)
    
  app.set "jsonp callback", true



###
# Authentication shinanigans
###

app.get "/auth", (req, res, next) ->
  if req.user then return res.json _.defaults req.auth,
    user: req.user

  res.json {}

app.del "/auth", (req, res, next) ->
  auths.del req.cookies.plnkr_token, (err) ->
    return next(err) if err
    res.clearCookie("plnkr_token", path: app.path or "/")
    res.send(204)

app.get "/auths/github", (req, res, next) ->
  return next(new require("./errors").MissingArgument("token")) unless req.query.token

  if req.user then return res.json _.defaults req.auth,
    user: req.user

  request.get "https://api.github.com/user?access_token=#{req.query.token}", (err, response, body) ->
    return next(new require("./errors").Error(err)) if err

    try
      body = JSON.parse(body)
    catch e
      return next(new require("./errors").InvalidJSON)

    return next(new require("./errors").Unauthorized(body)) if response.status >= 400

    # Create a new authorization
    createAuth = (err, user) ->
      return next(err) if err

      auth =
        id: "tok-#{genid()}"
        user_key: user_key
        service: "github"
        service_token: req.query.token

      auths.set auth.id, auth, (err) ->
        return next(err) if err

        json = _.defaults auth,
          user: user

        res.cookie "plnkr_token", auth.id,
          expires: new Date(Date.now() + 1000 * 60 * 60 * 24 * 7) # One week
          domain: url.parse(nconf.get("url:api")).host
          path: if nconf.get("nosubdomains") then app.route else "/"
        res.json json, 201

    # Create user if not exists
    user_key = "github:#{body.id}"

    users.get user_key, (err, user) ->
      unless user
        user = body
        users.set user_key, user, createAuth
      else createAuth(null, user)



###
# Plunks
###

async = require("async")

process =
  create: (context = {}) ->    
    steps = []
    
    finalize = (args..., cb) ->
      waterfall = _.map steps, _.identity
      
      # Fully apply the arguments supplied to the callback waterfall
      waterfall.unshift (next) -> next(null, args...)

      async.waterfall(waterfall, cb)
    
    # Interface to add a step
    finalize.addStep = (name, step) -> steps.push(step)
    
    finalize.runInContext = (context, args..., cb) ->
      waterfall = _.map steps, (step) -> _.bind(step, context)
      
      # Fully apply the arguments supplied to the callback waterfall
      waterfall.unshift (next) -> next(null, args...)

      async.waterfall(waterfall, cb)
      
    finalize
  
    

creater = process.create()
creater.addStep "validate_schema", (json, next) ->
  console.log "Validating", json
  schema = require("./schema/plunks/create")
  {valid, errors} = revalidator.validate(json, schema)
  
  # Despite its awesomeness, revalidator does not support disallow or additionalProperties; we need to check plunk.files size
  if json.files and _.isEmpty(json.files)
    valid = false
    errors.push
      attribute: "minProperties"
      property: "files"
      message: "A minimum of one file is required"
  
  if valid then next(null, json)
  else next(new apiErrors.ValidationError(errors))

creater.addStep "plunk_details", (json, next) ->
  
  if @user then json.user = @user.id
  
  next null, _.defaults json,
    description: ""
    created_at: (new Date()).toISOString()
    
creater.addStep "file_details", (json, next) ->
  _.each json.files, (file, filename) ->
    _.extend file,
      filename: filename
      mime: mime.lookup(filename, "text/plain")
  
  next(null, json)


creater.addStep "save", (json, next) ->
  generateUniqueId = (cb) ->
    uid = genid(6)
    
    plunks.get uid, (err, data) ->
      if err then cb(err)
      else if data then generateUniqueId(cb)
      else cb(null, uid)
  
  generateUniqueId (err, id) ->
    if err then cb(err)
    else plunks.set id, json, (err) -> next(err, id, _.clone(json))    
    

preparer = process.create()

preparer.addStep "response_fields", (id, plunk, next) ->
  _.extend plunk,
    id: id
    url: nconf.get("url:api") + "/plunks/#{id}"
    raw_url: nconf.get("url:raw") + "/#{id}"
    
  _.map plunk.files, (file, filename) ->
    file.raw_url = "#{plunk.raw_url}/#{filename}"
  
  next(null, plunk)
  
preparer.addStep "user_details", (plunk, next) ->
  if plunk.user then users.get plunk.user_id, (err, user) ->
    if err then next(err)
    else if user is null then next(new apiError.InternalError("Unable to fetch user"))
    else next null, _.extend plunk,
      user: user
  else next(null, plunk)

preparer.addStep "index", (plunk, next) ->
  filenames = _.keys(plunk.files)
  
  plunk.index ||= 
    if "index.html" in filenames then "index.html"
    else if "index.htm" in filenames then "index.htm"
    else _.find(filenames, ((filename) -> /.html?$/.test(filename))) or filenames[0]
  
  next(null, plunk)
  

app.post "/plunks", (req, res, next) ->
  creater.runInContext {user: req.user}, req.body, (err, id, plunk) ->
    if err then next(err)
    else preparer id, plunk, (err, plunk) ->
      if err then next(err)
      else res.json(plunk, 201)


app.get "/plunks", (req, res, next) ->
  

