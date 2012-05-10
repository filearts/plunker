_ = require("underscore")._

module.exports.middleware = (config = {}) ->
  (req, res, next) ->
    next()
