coffee = require("coffee-script")
less = require("less")
jade = require("jade")
express = require("express")
gzippo = require("gzippo")
assets = require("connect-assets")
nconf = require("nconf")

module.exports = app = express.createServer()


###
# Configure passport
###

passport = require("passport")
GitHubStrategy = require("passport-github").Strategy

passport.serializeUser (user, done) ->
  done(null, user)

passport.deserializeUser (obj, done)->
  done(null, obj)

passport.use new GitHubStrategy {
    clientID: nconf.get("oauth:github:id"),
    clientSecret: nconf.get("oauth:github:secret"),
    callbackURL: "#{nconf.get('url:www')}/auth/github/callback"
  }, (accessToken, refreshToken, profile, done) ->
    profile.token = accessToken
    done(null, profile)
    
###
# Configure the server
###

app.configure ->
  app.use assets(src: "#{__dirname}/assets")
  app.use gzippo.staticGzip("#{__dirname}/static")
  app.use express.cookieParser()
  app.use express.bodyParser()
  app.use express.session({ secret: "plnkr.co secret key" })
  app.use passport.initialize()
  app.use passport.session()
  app.use (req, res, next) ->
    res.local("package", require("../../package"))
    next()

  app.set "views", "#{__dirname}/views"
  app.set "view engine", "jade"
  app.set "view options", layout: false


app.get "/", (req, res) ->
  res.render "landing"