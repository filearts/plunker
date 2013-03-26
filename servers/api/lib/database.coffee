mongoose = require("mongoose")
nconf = require("nconf")
mime = require("mime")
url = require("url")
mime = require("mime")

plunkerDb = mongoose.createConnection "mongodb:" + url.format(nconf.get("mongodb"))
#packagesDb = mongoose.createConnection "mongodb:" + url.format(nconf.get("packager"))

plunkerDbTimeout = setTimeout(errorConnecting, 1000 * 30)
#packagesDbTimeout = setTimeout(errorConnecting, 1000 * 30)

apiUrl = nconf.get('url:api')
wwwUrl = nconf.get('url:www')
runUrl = nconf.get('url:run')

errorConnecting = ->
  console.error "Error connecting to mongodb"
  process.exit(1)
  
plunkerDb.on "open", -> clearTimeout(plunkerDbTimeout)
#packagesDb.on "open", -> clearTimeout(packagesDbTimeout)

{Schema, Document, Query} = mongoose
{ObjectId, Mixed} = Schema.Types

genid = (len = 16, prefix = "", keyspace = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789") ->
  prefix += keyspace.charAt(Math.floor(Math.random() * keyspace.length)) while len-- > 0
  prefix


# Change object _id to normal id
Document::toJSON = ->
  json = @toObject(json: true, virtuals: true)
  json.id = json._id if json._id
  delete json._id
  delete json.__v
  
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

exports.Session = plunkerDb.model "Session", SessionSchema



exports.User = plunkerDb.model "User", UserSchema = new Schema
  login: { type: String, index: true }
  gravatar_id: String
  service_id: { type: String, index: { unique: true } }
  profile: {}


PlunkFileSchema = new Schema
  filename: String
  content: String
  
PlunkFileSchema.virtual("mime").get -> mime.lookup(@filename, "text/plain")
  
PlunkVoteSchema = new Schema
  user: { type: Schema.ObjectId, ref: "User" }
  created_at: { type: Date, 'default': Date.now }

PlunkChangeSchema = new Schema
  fn: String # Current/new filename
  pn: String # Previous filename
  pl: String # Payload (contents / diff)

PlunkHistorySchema = new Schema
  event: { type: String, 'enum': ["create", "update", "fork"] }
  user: { type: Schema.ObjectId, ref: "User" }
  changes: [PlunkChangeSchema]
  
PlunkHistorySchema.virtual("created_at").get -> new Date(parseInt(@_id.toString().substring(0, 8), 16) * 1000)

PlunkSchema = new Schema
  _id: { type: String, index: true }
  description: String
  score: { type: Number, 'default': Date.now }
  thumbs: { type: Number, 'default': 0 }
  created_at: { type: Date, 'default': Date.now }
  updated_at: { type: Date, 'default': Date.now }
  token: { type: String, 'default': genid.bind(null, 16) }
  'private': { type: Boolean, 'default': false }
  source: {}
  files: [PlunkFileSchema]
  user: { type: Schema.ObjectId, ref: "User", index: true }
  comments: { type: Number, 'default': 0 }
  fork_of: { type: String, ref: "Plunk", index: true }
  forks: [{ type: String, ref: "Plunk", index: true }]
  tags: [{ type: String, index: true}]
  voters: [{ type: Schema.ObjectId, ref: "Users", index: true }]
  history: [PlunkHistorySchema]
  
PlunkSchema.index(score: -1, updated_at: -1)
PlunkSchema.index(thumbs: -1, updated_at: -1)

PlunkSchema.virtual("url").get -> apiUrl + "/plunks/#{@_id}"
PlunkSchema.virtual("raw_url").get -> runUrl + "/plunks/#{@_id}/"
PlunkSchema.virtual("comments_url").get -> wwwUrl + "/#{@_id}/comments"

exports.Plunk = plunkerDb.model "Plunk", PlunkSchema



PackageVersionSchema = new Schema
  semver: String
  scripts: [String]
  styles: [String]

PackageSchema = new Schema
  name: { type: String, match: /^[-_.a-z0-9]+$/i, index: true, unique: true }
  description: { type: String }
  homepage: String
  keywords: [{type: String, index: true}]
  versions: [PackageVersionSchema]
  maintainers: [{ type: String, index: true }]
  
PackageSchema.index {
  name: "text"
  description: "text"
  keywords: "text"
}, {
  name: "typeahead"
  weights:
    name: 3
    description: 1
    keywords: 2
}

exports.Package = plunkerDb.model "Package", PackageSchema
