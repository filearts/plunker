mime = require("mime")
revalidator = require("revalidator")
_ = require("underscore")._

apiErrors = require("../../errors")
schema = require("../../schema/plunks/create")

genid = (len = 16, prefix = "", keyspace = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789") ->
  prefix += keyspace.charAt(Math.floor(Math.random() * keyspace.length)) while len-- > 0
  prefix


###
# Creater
#
# Process that takes raw json sent to the RESTful API and creates a plunk in the
# database if that json validates.
#
###
module.exports = creater = []

creater.push (json, next) ->
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

creater.push (json, next) ->
  if @user and @user.id then json.user = @user.id
  
  next null, _.defaults json,
    description: ""
    created_at: (new Date()).toISOString()
    token: genid(16)
    
creater.push (json, next) ->
  _.each json.files, (file, filename) ->
    _.extend file,
      filename: filename
      mime: mime.lookup(filename, "text/plain")
  
  next(null, json)


creater.push (json, next) ->
  context = @
  
  generateUniqueId = (cb) ->
    uid = genid(6)
    
    context.plunks.get uid, (err, data) ->
      if err then cb(err)
      else if data then generateUniqueId(cb)
      else cb(null, uid)
  
  generateUniqueId (err, id) ->
    if err then cb(err)
    else context.plunks.set id, json, (err) -> next(err, id, _.clone(json))
