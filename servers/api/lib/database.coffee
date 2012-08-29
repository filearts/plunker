mongoose = require("mongoose")
nconf = require("nconf")
mime = require("mime")
url = require("url")

mongoose.connect "mongodb:" + url.format(nconf.get("mongodb"))

connectTimeout = setTimeout(errorConnecting, 1000 * 30)

apiUrl = nconf.get('url:api')
wwwUrl = nconf.get('url:www')
rawUrl = nconf.get('url:raw')

errorConnecting = ->
  console.error "Error connecting to mongodb"
  process.exit(1)
  
mongoose.connection.on "open", -> clearTimeout(connectTimeout)

{Schema, Document, Query} = mongoose
{ObjectId} = Schema

genid = (len = 16, prefix = "", keyspace = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789") ->
  prefix += keyspace.charAt(Math.floor(Math.random() * keyspace.length)) while len-- > 0
  prefix


# Change object _id to normal id
Document::toJSON = ->
  json = @toObject(json: true, virtuals: true)
  json.id = json._id
  delete json._id
  
  json
  
Query::paginate = (page, limit, cb) ->
  page = Math.max(1, parseInt(page, 10))
  limit = Math.max(4, Math.min(12, parseInt(limit, 10))) # [4, 10]
  query = @
  model = @model
  
  query.skip(page * limit - limit).limit(limit).exec (err, docs) ->
    if err then return cb(err, null, null)
    model.count query._conditions, (err, count) ->
      if err then return cb(err, null, null)
      cb(null, docs, count, Math.ceil(count / limit), page)
  
lastModified = (schema, options = {}) ->
  schema.add updated_at: Date
  schema.pre "save", (next) ->
    @updated_at = new Date
    next()
  
  if options.index then schema.path("updated_at").index(options.index)
  
TokenSchema = new Schema
  _id: String
  token: String


SessionSchema = new Schema
  user:
    type: Schema.ObjectId
    ref: "User"
  last_access: { type: Date, index: true, 'default': Date.now }
  public_id: { type: String, 'default': genid }
  auth: {}
  keychain: [TokenSchema]

SessionSchema.virtual("url").get -> apiUrl + "/sessions/#{@_id}"
SessionSchema.virtual("user_url").get -> apiUrl + "/sessions/#{@_id}/user"
SessionSchema.virtual("age").get -> Date.now() - @last_access

SessionSchema.plugin(lastModified)

SessionSchema.statics.prune = (max_age = 1000 * 60 * 60 * 24 * 7 * 2, cb = ->) ->
  @find({}).where("last_access").lt(new Date(Date.now() - max_age)).remove()

mongoose.model "Session", SessionSchema



mongoose.model "User", UserSchema = new Schema
  login: { type: String, index: true }
  gravatar_id: String
  service_id: { type: String, index: { unique: true } }
  profile: {}


PlunkFileSchema = new Schema
  filename: String
  content: String
  mime: String

PlunkSchema = new Schema
  _id: { type: String, index: true }
  description: String
  created_at: { type: Date, 'default': Date.now }
  updated_at: { type: Date, 'default': Date.now }
  token: { type: String, 'default': genid.bind(null, 16) }
  source: {}
  files: [PlunkFileSchema]
  user: { type: Schema.ObjectId, ref: "User", index: true }
  comments: { type: Number, 'default': 0 }
  fork_of: { type: String, ref: "Plunk", index: true }
  forks: [{ type: String, ref: "Plunk", index: true }]
  tags: [{ type: String, index: true}]
  voters: [{ type: Schema.ObjectId, ref: "User"}]

PlunkSchema.virtual("url").get -> apiUrl + "/plunks/#{@_id}"
PlunkSchema.virtual("raw_url").get -> rawUrl + "/#{@_id}/"
PlunkSchema.virtual("comments_url").get -> wwwUrl + "/#{@_id}/comments"

#PlunkSchema.plugin(pagination)

#PlunkSchema.plugin(lastModified)

mongoose.model "Plunk", PlunkSchema

module.exports = mongoose