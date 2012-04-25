resourceful = require("resourceful")
request = require("request")
express = require("express")

module.exports = app = express.createServer()

genid = (len = 16, prefix = "", keyspace = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789") ->
  prefix += keyspace.charAt(Math.floor(Math.random() * keyspace.length)) while len-- > 0
  prefix


Auth = resourceful.define "auth", ->
  @string "token"
  @object "user"
  @string "service"
  @string "service_token"


app.configure ->
  app.use require("./middleware/json").middleware()


app.get "/auth/github", (req, res, next) ->
  return res.next(new require("./errors").MissingArgument("token")) unless req.query.token
  
  request.get "https://api.github.com/user?access_token=#{req.query.token}", (err, response, body) ->
    return res.next(new require("./errors").Error(err)) if err
    
    try
      body = JSON.parse(body)
    catch e
      return res.next(new require("./errors").InvalidJSON)
    
    return res.next(new require("./errors").Unauthorized(body)) if response.status >= 400
    
    auth = new Auth
      _id: "github:#{body.id}"
      token: genid()
      user: body
      service: "github"
      service_token: req.query.token
    
    auth.save (err, user) ->
      return next(require("./errors").Error(err)) if err
      
      res.json(user.toJSON(), user.status)

