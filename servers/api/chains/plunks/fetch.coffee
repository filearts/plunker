###
# Fetcher
#
# Process that fetches a plunk from the database and passes control on in a
# format that further processes (like prepare) can handle.
#
###

apiErrors = require("../../errors")

module.exports = fetcher = []

fetcher.push (id, next) ->
  @plunks.get id, (err, plunk) ->
    if err then next(err)
    else unless plunk then next(new apiErrors.NotFound)
    else next(err, id, plunk)