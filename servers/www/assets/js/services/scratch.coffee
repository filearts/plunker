#= require ../vendor/angular

#= require ../services/plunks
#= require ../services/importer
#= require ../services/session


###
Service representing the transient state of the editor

This service holds the single source of truth for everything related to the
editor's state. It holds a reference to the active plunk that it affects upon
request.

The scratch is a 'smart' application specific layer on top of the dumb plunk
data service.

It is important to note that changes propagate one-way from the scratch to the
plunk. Making changes to the plunk directly will probably not have the desired
effect.

###
module = angular.module("plunker.scratch", ["plunker.plunks", "plunker.importer"])

module.factory "scratch", ["$location", "$q", "Plunk", "importer", "session", ($location, $q, Plunk, importer, session) ->
  ###
  Class to handle the list of active buffers
  ###
  class Buffers
    constructor: ->
      @queue = []
    
    at: (idx = 0) -> @queue[idx]
    active: -> @at(0)
    
    activate: (active) ->
      # Take it out and put it in the front
      @remove(active)
      @queue.unshift(active)
      @
    
    findBy: (key, value) ->
      return object for object in @queue when object[key] == value
    
    add: (add) ->
      @queue.push(new Buffer(add))
      @
    
    remove: (remove) ->
      if (idx = @queue.indexOf(remove)) >= 0
        @queue.splice(idx, 1)
      @
      
    reset: (queue = []) ->
      @queue.length = 0
      @add(item) for item in queue
      @
    
  ###
  Class representing an active file in the editor
  ###
  class Buffer
    nextID: do ->
      counter = 1
      -> "Untitled#{counter++}"
      
    constructor: (attributes = {}) ->
      angular.copy(attributes, @)
      
      @content ||= ""
      @filename ||= @nextID()
      
      @old_filename = @filename if @filename
    
    getDelta: (file) ->
      delta = {}
      delta.filename = @filename unless file.filename is @filename
      delta.content = @content unless file.content is @content
      
      return delta if delta.filename? or delta.content?
      
  
  new class Scratch
    @emptyPlunk:
      description: ""
      files: { "index.html": {filename: "index.html", content: ""} }
      
    constructor: ->
      @description = ""
      @tags = []
      
      @buffers = new Buffers
      @plunk = new Plunk
      
      @loading = false
    
    reset: (json = Scratch.emptyPlunk) ->
      @plunk.reset(angular.copy(json))

      # Save a copy of the loaded json if the plunk belongs to this session
      # There is no need for a saved state if the active user is not the owner
      if @isSaved() and @isOwned() then angular.copy(json, @savedState)
      else delete @savedState
      
      @buffers.reset(file for filename, file of json.files)
      @buffers.activate(index) if index = @buffers.findBy("filename", "index.html")
      
      @
      
    _doAsync: (fn) ->
      self = @
      self.loading = true

      deferred = $q.defer()
      deferred.promise.then ->
        self.loading = false
      , ->
        self.loading = false
        
      fn.call(self, deferred)
      
      deferred.promise

      
    save: -> @_doAsync (deferred) ->
      self = @
      
      @plunk.description ||= "Untitled"
      
      json =
        description: @plunk.description
        #tags: @plunk.tags
        files: {}
      
      # There is a saved state, today is not our lucky day; all kinds of ugly
      # needed
      if @savedState
        delete json.description if angular.equals(@plunk.description, @savedState.description)
        delete json.tags if angular.equals(@plunk.tags, @savedState.tags)
        
        # Look for files that no longer exist and mark them for deletion
        for filename, file of @savedState.files
          json.files[filename] = null unless @buffers.findBy("filename", filename)
      
        # Look at existing files and add deltas
        for buffer in @buffers.queue
          key = buffer.old_filename or buffer.filename
          
          if old = @savedState.files[key]
            # Existing file; check delta
            json.files[key] = delta if delta = buffer.getDelta(old)
          else
            # New file
            json.files[key] = content: buffer.content
        
      else
        for buffer in @buffers.queue
          json.files[buffer.filename] =
            filename: buffer.filename
            content: buffer.content
      
      count = 0
      count++ for filename, file of json.files
      
      if count or json.description or json.tags
        old_id = @plunk.id
        
        @plunk.save json, (plunk) ->
          angular.copy(plunk, self.savedState)
          buffer.old_filename = buffer.filename for buffer in self.buffers.queue
          
          $location.path("/#{plunk.id}")
          $location.replace() unless old_id and old_id != plunk.id
          
          deferred.resolve(arguments...)
        , ->
          deferred.reject(arguments...)
      else
        console.warn "Save cancelled: No changes to save"
        deferred.reject("Save cancelled: No changes to save")
    
    destroy: -> @_doAsync (deferred) ->
      if @isSaved() and @isOwned()
        @plunk.destroy ->
          @savedState = null
          
          deferred.resolve(arguments...)
        , ->
          deferred.reject(arguments...)

    loadFrom: (source) -> @_doAsync (deferred) ->
      self = @

      importer.import(source).then (json) ->
        self.reset(json)
        deferred.resolve(@)
      , (msg) ->
        $location.path("/").replace()
        deferred.reject("Import failed: #{msg}")

    addFile: (filename, content = "") ->
      if @buffers.findBy("filename", filename)
        console.error("Attempt to add an existing file, '#{filename}'")
        return @
      
      @buffers.add
        filename: filename
        content: content
      
      @

    removeFile: (filename) ->
      unless buffer = @buffers.findBy("filename", filename)
        console.error("Attempt to remove a non-existing file, '#{filename}'")
        return @
      
      @buffers.remove(buffer)
      
      @
    
    renameFile: (filename, new_filename) ->
      unless buffer = @buffers.findBy("filename", filename)
        console.error("Attempt to rename a non-existing file, '#{filename}'")
        return @
      
      buffer.filename = new_filename
      
      @

    getFile: (filename) -> @buffers.findBy("filename", filename)

    isOwned: -> not @isSaved() or !!@plunk.token
    isSaved: -> !!@plunk.id
    
    promptDestroy: ->
      @destroy() if confirm("Are you sure that you would like to destroy this plunk?")
    
    promptFileAdd: (new_filename) ->
      if new_filename ||= prompt("Please enter the name for the new file:")
        if @getFile(new_filename) then alert("A file already exists called: '#{new_filename}'")
        else @addFile(new_filename)
    
    promptFileRemove: (filename) ->
      if @getFile(filename) and confirm("Are you sure that you would like to remove the file '#{filename}'?")
        @removeFile(filename)
        @addFile("index.html") unless @buffers.queue.length > 0
    
    promptFileRename: (filename, new_filename) ->
      if @getFile(filename) and (new_filename ||= prompt("Please enter the name for new name for the file:"))
        if @getFile(new_filename) then alert("A file already exists called '#{new_filename}'")
        else @renameFile(filename, new_filename)

]