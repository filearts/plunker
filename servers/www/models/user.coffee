resourceful = require("resourceful")

module.exports.User = resourceful.define "user", ->
  @string "login"
  @string "gravatar_id"
  @string "html_url"
  @string "url"
