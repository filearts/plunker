_ = require("underscore")._

module.exports.middleware = (config = {}) ->
  (req, res, next) ->
    if req.session
    if auth = req.header("Authorization") then [header, token] = auth.match(/^token (\S+)$/i)
    next()
