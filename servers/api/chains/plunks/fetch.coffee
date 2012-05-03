###
# Fetcher
#
# Process that fetches a plunk from the database and passes control on in a
# format that further processes (like prepare) can handle.
#
###

module.exports = fetcher = []

fetcher.push (id, next) ->
  @plunks.get id, (err, plunk) ->
    next(err, id, plunk)