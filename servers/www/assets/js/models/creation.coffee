#= require ../models/plunks

#= require ../lib/importer
#= require ../lib/mime

((plunker) ->
  
  EditSession = require("ace/edit_session").EditSession
  UndoManager = require("ace/undomanager").UndoManager
  


  # Model to represent a text buffer in a Plunker session
  class Buffer extends Backbone.Model
    idAttribute: "filename"
    defaults: ->
      filename: "Untitled-#{@cid}"
      content: ""
      
    initialize: ->
      self = @

      @session = new EditSession(@get("content") or "")
      
      @session.setTabSize(2)
      @session.setUseSoftTabs(true)
      @session.setUndoManager(new UndoManager())
      
      @session.on "change", -> self.set("content", self.session.getValue())   

      @setMode()
        
      @on "change:filename", @setMode
      
    
    setMode: =>
      if (mime = plunker.mime.findByFilename(@get("filename"))) and mime.name
        @session.setMode("ace/mode/#{mime.name}")
        @set("mime", mime)

  class BufferCollection extends Backbone.Collection
    model: Buffer
    comparator: (model) -> model.id and model.id.toLowerCase()

  class plunker.Creation extends Backbone.Model
    initialize: ->
      @plunk = new plunker.Plunk
      @buffers = new BufferCollection
      
      self = @
      
      plunker.mediator.on "file:activate", (filename) ->
        self.buffers.each (buffer) -> buffer.set("active", buffer.id is filename)
        self.set("active", filename)
        
      @buffers.on "reset", (coll) ->
        plunker.mediator.trigger "intent:file:activate", self.guessStartingFilename()

      @queue = []
      
      @buffers.on "add", (model) -> self.queue.unshift model.get("filename")
      @buffers.on "remove", (model) -> self.queue = _.without self.queue, model.get("filename")
      @buffers.on "reset", (coll) -> self.queue = coll.pluck("filename")
      
      plunker.mediator.on "file:rename", (to, from) -> self.queue = _.map self.queue, (el) -> if el == from then to else el
      plunker.mediator.on "file:activate", (filename) -> self.queue = [filename].concat _.without(self.queue, filename)

      @on "import:start", -> plunker.mediator.trigger "editor:disable"
      @on "import:error import:success", -> plunker.mediator.trigger "editor:enable"

      plunker.mediator.on "prompt:file:add", @onPromptFileAdd

      plunker.mediator.on "intent:file:activate", @onIntentFileActivate
      plunker.mediator.on "intent:file:add", @onIntentFileAdd
      plunker.mediator.on "intent:file:delete", @onIntentFileDelete
      
      plunker.mediator.on "intent:save", @onIntentSave
      
      setOwnStatus = ->
        self.ownStatusRef.removeOnDisconnect()
        self.ownStatusRef.set plunker.user.get("login") or plunker.session.get("public_id")

      
      @plunk.on "change:id", ->
        id = self.plunk.id
        previous = self.plunk.previous("id")
        ownId = plunker.user.get("login") or plunker.session.get("public_id")
        
        if previous isnt id
          if previous
            presenceRef = new Firebase("http://gamma.firebase.com/filearts/#{self.plunk.id}/editors/#{ownId}")
            presenceRef.remove()
            
          if id
            presenceRef = new Firebase("http://gamma.firebase.com/filearts/#{self.plunk.id}/editors")
            
            self.ownStatusRef.remove() if self.ownStatusRef
            
            self.ownStatusRef = presenceRef.child(plunker.session.get("public_id"))
            self.ownStatusRef.on "value", (snapshot) ->
              setOwnStatus() if snapshot.val() is null
            
            
            plunker.router.navigate "/edit/#{id}", replace: true, trigger: false


    
    onPromptFileAdd: (e) ->
      if filename = prompt("Please enter the filename")
        plunker.mediator.trigger "intent:file:add", filename

    onIntentFileActivate: (filename) =>
      if @buffers.get(filename)
        plunker.mediator.trigger "file:activate", filename
    
    onIntentFileAdd: (filename) =>
      if filename and not @buffers.get(filename)
        @buffers.add
          filename: filename
        
        plunker.mediator.trigger "intent:file:activate", filename
    
    onIntentFileDelete: (filename) =>
      last = @last()
      
      if buffer = @buffers.get(filename) and confirm("Are you sure you would like to delete #{filename}?")
        @buffers.remove(filename)
        
        if last is filename
          plunker.mediator.trigger "intent:file:activate", @last()
          
    onIntentSave: =>
      files = {}
      
      @buffers.each (buffer) ->
        files[buffer.id] =
          content: buffer.get("content")
      
      @plunk.set
        description: @get("description")
        files: files
        
      @plunk.save {},
        success: -> plunker.mediator.trigger "save", @plunk
        error: -> plunker.mediator.trigger "save:error", arguments...
    
    last: -> _.first(@queue)
    getActiveBuffer: -> @buffers.get(@last())
    guessStartingFilename: ->
      unless @buffers.length then plunker.mediator.trigger "error", "Impossible to guess starting filename"
      else (@buffers.get("index.html") or @buffers.at(0)).id

    
    import: (source, options = {}) ->
      self = @
      
      self.trigger "import:start"
      
      options = _.defaults options,
        success: ->
        error: ->
      
      plunker.import source, (err, json) ->
        if err or not json
          self.trigger "import:error", @
          options.error(err or "That is not a recognized source")
        else
          self.set
            description: json.description
            source: json.source
            
          self.buffers.reset _.map json.files, (file, filename) -> _.defaults file,
            filename: filename
          
          options.success(@) 
          self.trigger "import:success", @

    load: (id, options = {}) ->
      self = @
      
      options = _.defaults options,
        success: ->
        error: ->
          
      onSuccess = options.success
      onError = options.error

      self.trigger "import:start"
      
      @plunk.clear().set("id", id).fetch
        success: (plunk) ->
          self.set
            description: plunk.get("description")
          
          self.buffers.reset _.values(plunk.get("files"))
          self.plunk.trigger "sync"
          self.trigger "import:success", @
          onSuccess(@)
        error: (err) ->
          onError(@)
          self.trigger "import:error"


)(@plunker or @plunker = {})