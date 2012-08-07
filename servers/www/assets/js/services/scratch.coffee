#= require ../vendor/angular

#= require ../services/plunks
#= require ../services/importer

module = angular.module("plunker.scratch", ["plunker.plunks", "plunker.importer"])

module.factory "scratch", ["$location", "Plunk", "importer", ($location, Plunk, importer) ->
  new class Scratch
    constructor: ->
      @plunk = new Plunk
      @loading = false
      @history = @getValidFiles()
      
      @activate(index) if index = @getFile("index.html")
        
    loadFrom: (source, success = angular.noop, error = angular.noop) ->
      self = @
      self.loading = true
      
      importer.import(source).then (json) ->
        self.plunk.constructor.call(self.plunk, json)
        self.history = self.getValidFiles()
        self.activate(index) if index = self.getFile("index.html")
        success(self)
        self.loading = false
      , (msg) ->
        error("Import failed: #{msg}")
        self.loading = false
      
      @
    
    reset: ->
      @plunk.constructor.call(self.plunk)
      @history = @getValidFiles()
      
      @
    
    save: (success = angular.noop, error = angular.noop) ->
      old_id = @plunk.id
      
      self = @
      self.plunk.save (plunk) ->
        $location.path("/#{plunk.id}")
        $location.replace() unless old_id and old_id != plunk.id
      , (msg) -> error("Save failed: #{msg}")
      
      @
    
    destroy: (success = angular.noop, error = angular.noop) ->
      self = @
      self.plunk.destroy ->
        $location.path("/").replace()
      , (msg) -> error("Delete failed: #{msg}")
      
      @

    addFile: (filename, options = {}) ->
      # It is possible that the user wants to add a file that already existed
      # but that was renamed. We don't want to overwrite that file. Instead, 
      # we will swap the files.
      if (existing = @plunk.files[filename]) and existing.filename isnt filename
        @plunk.files[existing.filename] = existing
        
      options.filename ||= filename
      options.content ||= ""
      
      @plunk.files[filename] = file = angular.copy(options)
      @history.unshift(file)
      
      @
    
    removeFile: (filename) ->
      removed = null
      
      for key, file of @plunk.files
        if file.filename == filename
          removed = file
          @plunk.files[key] = null
          break
          
      if removed and (idx = @history.indexOf(removed)) >= 0
        @history.splice(idx, 1)
      
      @
    
    renameFile: (old_filename, new_filename) ->
      for key, file of @plunk.files
        if file.filename == old_filename
          file.filename = new_filename
          break
      
      @
    
    active: -> @history[0]
    
    activate: (file) ->
      if (idx = @history.indexOf(file)) >= 0
        @history.splice(idx, 1)
      
      #$location.hash(file.filename).replace()
      
      @history.unshift(file)
       
    getFile: (filename) ->
      for key, file of @plunk.files
        if file.filename is filename then return file
    
    # Get an array of valid (non-null) files
    getValidFiles: ->
      files = []
      files.push(file) for filename, file of @plunk.files when file isnt null
      files

    isOwner: -> @plunk.isOwner()
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
        @addFile("index.html") unless @getValidFiles().length > 0
    
    promptFileRename: (filename, new_filename) ->
      if @getFile(filename) and (new_filename ||= prompt("Please enter the name for new name for the file:"))
        if @getFile(new_filename) then alert("A file already exists called '#{new_filename}'")
        else @renameFile(filename, new_filename)
]