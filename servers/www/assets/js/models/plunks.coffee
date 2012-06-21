((plunker) ->

  sync = (method, model, options = {}) ->
    params = _.extend {}, options,
      url: model.url()
      cache: false
      headers: options.headers or {}
    
    switch method
      when "create"
        params.type = "post"
        params.headers = "Content-Type": "application/json"
        params.data = JSON.stringify(model.toJSON())
      when "read"
        params.type = "get"
      when "update"
        params.type = "post"
        params.headers = "Content-Type": "application/json"
        params.data = JSON.stringify(model._changes)
      when "delete"
        params.type = "delete"

    plunker.request(params)

  class plunker.Plunk extends Backbone.Model
    url: => @get("url") or plunker.router.url("api") + "/plunks" + if @id then "/#{@id}" else ""
    sync: sync
    defaults: ->
      description: ""
      files: {}

    initialize: ->
      self = @

      @_changes = {}
      @_synced = {files: {}}

      @on "sync", ->
        # Reset synced state and changes
        self._changes = {}
        self._synced = _.clone(self.attributes)
      
      # Handle simple changes
      _.each ["description", "index", "expires"], (key) ->
        self.on "change:#{key}", (model, value, options) ->
          self._changes[key] = value unless value == self._synced[key]

      # Handle changes to files
      @on "change:files", (model, files, options) ->
        previous = _.clone(self._synced.files) or {}
        created = _.clone(files)
        changes = {}

        delete self.changes.files if self.changes # Kill the old changes; the whole files hash changes

        for filename, file of previous
          former = previous[filename]
          updated = files[filename]
          
          delete created[filename]
          
          # Check for deletion (file doesn't exist in new files)
          unless updated
            changes[filename] = null
          else if updated.filename isnt former.filename or updated.content isnt former.content
            changes[filename] = {}
            changes[filename].filename = updated.filename if updated.filename isnt former.filename
            changes[filename].content = updated.content if updated.content isnt former.content

        _.extend changes, created
        
        self._changes.files = changes unless _.isEmpty(changes)
    
    getEditUrl: -> plunker.router.url("www") + "/edit/#{@id}"
    getPreviewUrl: -> plunker.router.url("www") + "/#{@id}"


  class plunker.PlunkCollection extends Backbone.Collection
    url: => @get("url") or plunker.router.url("api") + "/plunks"
    model: plunker.Plunk
    comparator: (model) -> -Date.parse(model.get("updated_at") or model.get("created_at"))
    sync: sync

)(@plunker or @plunker = {})