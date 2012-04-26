events = require("events")
fs = require("fs")
_ = require("underscore")._


class module.exports.Database extends events.EventEmitter
  constructor: (@filename) ->
    @items = {}
    @_save = _.throttle(@_save, 1000 * 60) # Max once a minute
    
    if @filename
      @_restore()
      @on "set", @_save
      @on "del", @_save
  
  get: (key, cb) ->
    value = @items[key]
    @emit "get", key, value
    cb(null, value)
  set: (key, value, cb) ->
    @items[key] = value
    @emit "set", value
    cb(null, value)
  del: (key, cb) ->
    value = @items[key]
    delete @items[key]
    @emit "del", key, value
    cb(null, value)
  
  _save: =>
    self = @
    
    console.info "[INFO] Writing backup to: #{@filename}"
    
    fs.writeFile @filename, JSON.stringify(@items), (err) ->
      if err then console.error "[ERR] Backup failed to: #{self.filename}"
      else console.log "[OK] Backup made to: #{self.filename}"
  
  _restore: =>
    self = @
    
    console.info "[INFO] Restoring from: #{@filename}"
    
    fs.readFile @filename, "utf8", (err, data) ->
      if err then console.error "[ERR] Restore failed from: #{self.filename}"
      else
        try
          _.extend self.items, JSON.parse(data)
        catch e
          return console.error "[ERR] Restore failed to parse from: #{self.filename}"

        console.log "[OK] Restore succeeded from: #{self.filename}"