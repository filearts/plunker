nconf = require("nconf")
_ = require("underscore")._

apiErrors = require("../../errors")

###
# Preparer
#
# Process that takes a plunk as saved in the database and prepares that data
# to be sent to a RESTful client. This process involves adding fields that
# are not necessary to save to the database.
#
###

module.exports = preparer = []

preparer.push (id, plunk, next) ->
  _.extend plunk,
    id: id
    url: nconf.get("url:api") + "/plunks/#{id}"
    raw_url: nconf.get("url:raw") + "/#{id}"
    
  _.map plunk.files, (file, filename) ->
    file.raw_url = "#{plunk.raw_url}/#{filename}"
  
  # Check tokens
  unless @tokens.has(plunk.token) or (@user and plunk.user == @user.id)
    delete plunk.token  
  
  next(null, plunk)
  
preparer.push (plunk, next) ->
  if plunk.user then @users.get plunk.user, (err, user) ->
    if err then next(err)
    else if user is null then next(new apiError.InternalError("Unable to fetch user"))
    else next null, _.extend plunk,
      user: user
  else next(null, plunk)

preparer.push (plunk, next) ->
  filenames = _.keys(plunk.files)
  
  plunk.index ||= 
    if "index.html" in filenames then "index.html"
    else if "index.htm" in filenames then "index.htm"
    else _.find(filenames, ((filename) -> /.html?$/.test(filename))) or filenames[0]
  
  next(null, plunk)