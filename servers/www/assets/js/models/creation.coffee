#= require ../vendor/ace/ace

#= require ../models/plunks

#= require ../lib/importer
#= require ../lib/mime

((plunker) ->
  
  EditSession = require("ace/edit_session").EditSession
  UndoManager = require("ace/undomanager").UndoManager
  

  # Model to represent a text buffer in a Plunker session
  class Buffer extends Backbone.Model
    idAttribute: "filename"
    initialize: ->
      self = @

      @session = new EditSession(@get("content") or "")
      
      @session.setTabSize(2)
      @session.setUseSoftTabs(true)
      @session.setUndoManager(new UndoManager())
      
      @set("filename", "Untitled-#{@cid}.txt") unless @id

      @setMode()
        
      @on "change:filename", @setMode
      
      @session.on "change", -> self.set("content", self.session.getValue())   
    
    setMode: ->
      if mime = plunker.mime.findByFilename(@get("filename"))
        @session.setMode("ace/mode/#{mime.name}")
        @set("mime", mime)

  class BufferCollection extends Backbone.Collection
    model: Buffer

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
      
      plunker.mediator.on "file:ename", (to, from) -> self.queue = _.map self.queue, (el) -> if el == from then to else el
      plunker.mediator.on "file:activate", (filename) -> self.queue = [filename].concat _.without(self.queue, filename)

      @on "import:start", -> plunker.mediator.trigger "editor:disable"
      @on "import:error import:success", -> plunker.mediator.trigger "editor:enable"

    
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
          
          self.trigger "import:success", @
          options.success(@) 

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
          
          self.trigger "import:success", @
          onSuccess(@)
        error: (err) ->
          self.trigger "import:error"
          onError(@)


)(@plunker or @plunker = {})