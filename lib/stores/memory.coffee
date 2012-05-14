events = require("events")
fs = require("fs")
_ = require("underscore")._


# From: http://stackoverflow.com/questions/728360/copying-an-object-in-javascript/728694#728694
clone = (obj) ->
  # Handle the 3 simple types, and null or undefined
  if (null == obj || "object" != typeof obj)
    return obj

  # Handle Date
  if (obj instanceof Date)
      copy = new Date()
      copy.setTime(obj.getTime())
      return copy

  # Handle Array
  if (obj instanceof Array) 
      copy = []
      for i, val in obj
        copy[i] = clone(val)
      return copy

  # Handle Object
  if (obj instanceof Object)
      copy = {}
      for own attr, val of obj
        copy[attr] = clone(val)
      return copy
  throw new Error("Unable to copy obj! Its type isn't supported.")


class module.exports.Database extends events.EventEmitter
  constructor: (@options = {}) ->
    @items = {}
    @keys = []
    
    @_save = _.throttle(@_save, 1000 * 60) # Max once a minute
    
    if @options.filename
      self = @
      @_restore -> # We don't want the event handlers to fire until restore is complete
        self.on "set", -> self._save()
        self.on "del", -> self._save()
  
  at: (index, cb) -> @get(@keys[index], cb)
  list: (start, end, cb) ->
    self = @
    mapped = _.map @keys.slice(start, end), (key, value) -> [key, clone(self.items[key])]
    cb null, mapped
    mapped
  
  get: (key, cb) ->
    value = clone(@items[key])
    
    @emit "get", key, value
    
    cb(null, value) if cb
    value
    
  set: (key, value, cb) ->
    @del(key) # To make sure that the sorted index is property reflected
    
    value = clone(value)
    
    index =
      if @options.comparator then _.sortedIndex(@items, value, @options.comparator)
      else 0 # Always add items to the front unless the comparator suggests otherwise
    
    @items[key] = value
    @keys.splice(index, 0, key)
    
    @emit "set", key, value
    
    cb(null, value) if cb
    value
    
  del: (key, cb) ->
    delete @items[key]
    
    if (index = @keys.indexOf(key)) >= 0
      @keys.splice(index, 1)
      @emit "del", key
    
    cb(null) if cb
    return
    
  _sleep: -> JSON.stringify(@items)
  _wakeup: (data) -> @set(key, value) for key, value of JSON.parse(data)
  
  _save: (cb) =>
    self = @
    
    console.info "[INFO] Writing backup to: #{@options.filename}"
    
    fs.writeFile @options.filename, @_sleep(), (err) ->
      if err then console.error "[ERR] Backup failed to: #{self.options.filename}"
      else console.log "[OK] Backup made to: #{self.options.filename}"
      
      cb() if cb
  
  _restore: (cb) =>
    self = @
    
    console.info "[INFO] Restoring from: #{@options.filename}"
    
    fs.readFile @options.filename, "utf8", (err, data) ->
      if err then console.error "[ERR] Restore failed from: #{self.options.filename}; * This is normal for your first run"
      else
        try
          self._wakeup(data)
        catch e
          return console.error "[ERR] Restore failed to parse from: #{self.options.filename}"

        console.log "[OK] Restore succeeded from: #{self.options.filename}"
      
      cb() if cb