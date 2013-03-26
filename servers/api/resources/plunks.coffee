nconf = require("nconf")
request = require("request")
url = require("url")
querystring = require("querystring")
_ = require("underscore")._
semver = require("semver")
diff_patch_match = new require("googlediff")
gate = require("json-gate")


gdiff = new diff_patch_match()
apiErrors = require("../errors")
apiUrl = nconf.get('url:api')
database = require("../lib/database")


Plunk = database.Plunk


exports.schema =
  create: gate.createSchema(require("./schema/plunks/create.json"))
  fork: gate.createSchema(require("./schema/plunks/fork.json"))
  update: gate.createSchema(require("./schema/plunks/update.json"))



genid = (len = 16, prefix = "", keyspace = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789") ->
  prefix += keyspace.charAt(Math.floor(Math.random() * keyspace.length)) while len-- > 0
  prefix

ownsPlunk = (session, json) ->
  owner = false
  
  if session
    owner ||= !!(json.user and session.user and json.user.login is session.user.login)
    owner ||= !!(session.keychain and session.keychain.id(json.id)?.token is json.token)

  owner
  
preparePlunk = (session, plunk, populate = {}) ->
  json = _.extend plunk.toJSON(), populate
  
  delete json.token unless ownsPlunk(session, json)
  delete json.voters
  
  if json.files then json.files = do ->
    files = {}
    for file in json.files
      file.raw_url = "#{json.raw_url}#{file.filename}"
      files[file.filename] = file
    files
  
  json.thumbed = session?.user? and plunk.voters.indexOf(""+session.user._id) >= 0
  
  json

preparePlunks = (session, plunks) -> _.map plunks, (plunk) -> preparePlunk(session, plunk)


createLinkHeaderString = (baseUrl, page, pages, limit) ->
  link = []
  
  if page < pages
    link.push "<#{baseUrl}?p=#{page+1}&pp=#{limit}>; rel=\"next\""
    link.push "<#{baseUrl}?p=#{pages}&pp=#{limit}>; rel=\"last\""
  if page > 1
    link.push "<#{baseUrl}?p=#{page-1}&pp=#{limit}>; rel=\"prev\""
    link.push "<#{baseUrl}?p=1&pp=#{limit}>; rel=\"first\""
  
  link.join(", ")
  


exports.createListing = (options = {}) ->
  options.baseUrl ||= "#{apiUrl}/plunks"
  options.query ||= {}
  
  (req, res, next) ->
    page = parseInt(req.param("p", "1"), 10)
    limit = parseInt(req.param("pp", "8"))

    # Filter on plunks that are visible to the active user
    if req.user
      options.query.$or = [
        'private': $ne: true
      ,
        user: req.user._id
      ]
    else
      options.query.private = $ne: true

    # Build the Mongoose Query
    query = Plunk.find(options.query)
    query.sort(options.sort or {updated_at: -1})
    query.select("-files") # We exclude files from plunk listings
    query.select("-history") # We exclude history from plunk listings
    
    query.populate("user").paginate page, limit, (err, plunks, count, pages, current) ->
      if err then next(err)
      else
        res.header("Link", link) if link = createLinkHeaderString(options.baseUrl, current, pages, limit)
        res.json(preparePlunks(req.session, plunks))


saveNewPlunk = (plunk, priv = true, cb) ->
  # Keep generating new ids until not taken
  savePlunk = ->
    plunk._id = if priv then genid(20) else genid(6)
  
    plunk.save (err) ->
      if err
        if err.code is 11000 then savePlunk()
        else
          console.error "[ERR]", err.message, err
          return cb(new apiErrors.DatabaseError)
      else return cb(null, plunk)
  
  savePlunk()

populatePlunk = (json, user, parent) ->
  plunk = new Plunk
  plunk.description = json.description ? "Untitled"
  plunk.private = json.private ? true
  plunk.source = json.source
  plunk.user = user._id if user
  plunk.fork_of = parent._id if parent
  plunk.tags.push(tag) for tag in json.tags
  
  for filename, file of json.files
    plunk.files.push
      filename: file.filename or filename
      content: file.content      
  
  plunk
  
exports.create = (req, res, next) ->
  event =
    event: "create"
  
  event.user = req.user._id if req.user
  
  plunk = populatePlunk(req.body, req.user)
  plunk.history.push(event)
  
  saveNewPlunk plunk, !!req.body.private, (err, plunk) ->
    if err then next(new apiErrors.NotFound)
    else
      unless req.user and req.session and req.session.keychain
        req.session.keychain.push _id: plunk._id, token: plunk.token
        req.session.save()
      
      json = preparePlunk req.session, plunk
      json.user = req.user.toJSON() if req.user
      
      res.json(json, 201)

exports.sendPlunk = (req, res, next) ->
  res.json preparePlunk(req.session, req.plunk)

exports.withPlunk = (req, res, next) ->
  Plunk.findById(req.params.id).populate("user").exec (err, plunk) ->
    if err or not plunk then next(new apiErrors.NotFound)
    else
      req.plunk = plunk
      next()
      
    
applyFilesDeltaToPlunk = (plunk, json) ->
  oldFiles = {}
  changes = []
  
  return changes unless json.files

  # Create a map of filename=>file (subdocument) of existing files
  for file, index in plunk.files
    oldFiles[file.filename] = file
  
  # For each change proposed in the json
  for filename, file of json.files
  
    # Attempt to delete
    if file is null
      if old = oldFiles[filename]
        changes.push
          pn: filename
          pl: old.content
        oldFiles[filename].remove() 
        
    # Modification to an existing file
    else if old = oldFiles[filename]
      chg =
        pn: old.filename
        fn: file.filename or old.filename
      
      if file.filename
        chg.fn = old.filename
        old.filename = file.filename
      if file.content?
        chg.pl = gdiff.patch_toText(gdiff.patch_make(file.content, old.content))
        old.content = file.content
      
      if chg.fn or file.filename
        changes.push(chg)
        
    # New file; handle only if content provided
    else if file.content
      changes.push
        fn: filename
        pl: file.content
      plunk.files.push
        filename: filename
        content: file.content
  
  changes

applyTagsDeltaToPlunk = (plunk, json) ->
  changes = []
  
  if json.tags
    plunk.tags ||= []
    
    for tagname, add of json.tags
      if add
        plunk.tags.push(tagname)
      else
        plunk.tags.splice(idx, 1) if (idx = plunk.tags.indexOf(tagname)) >= 0
  
  changes


exports.update = (req, res, next) ->
  return next(new Error("request.plunk is required for update()")) unless req.plunk
  
  event =
    event: "update"
    changes: []
    
  event.user = req.user._id if req.user
  
  event.changes.push(e) for e in applyFilesDeltaToPlunk(req.plunk, req.body)
  event.changes.push(e) for e in applyTagsDeltaToPlunk(req.plunk, req.body)
              
        
  req.plunk.updated_at = new Date
  req.plunk.description = req.body.description if req.body.description
  req.plunk.user = req.user._id if req.user
  
  req.plunk.history.push(event)
        
  req.plunk.save (err) ->
    if err then next(new apiErrors.InternalServerError(err))
    else
      populate = user: req.user.toJSON() if req.user
          
      res.json(preparePlunk(req.session, req.plunk, populate))

exports.fork = (req, res, next) ->
  return next(new Error("request.plunk is required for update()")) unless req.plunk

  event =
    event: "fork"
  
  event.user = req.user._id if req.user
  
  fork = populatePlunk(req.body, req.user, req.plunk)
  fork.history.push(event)
  
  saveNewPlunk fork, !!req.body.private, (err, plunk) ->
    if err then next(new apiErrors.NotFound)
    else
      unless req.user and req.session and req.session.keychain
        req.session.keychain.push _id: plunk._id, token: plunk.token
        req.session.save()
      
      json = preparePlunk req.session, plunk
      json.user = req.user.toJSON() if req.user
      
      req.plunk.forks.push(plunk._id)
      req.plunk.save()
      
      res.json(json, 201)

