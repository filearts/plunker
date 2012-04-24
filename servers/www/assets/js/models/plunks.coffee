((plunker) ->
  
  sync = (method, model, options = {}) ->
    params = _.extend {}, options,
      url: if model.isNew() then model.collection.url() else model.url()
      cache: false
      dataType: "json"

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
        params.data = JSON.stringify(model.changes)
      when "delete"
        params.type = "delete"
        
    $.ajax(params)
  
  class plunker.Plunk extends Backbone.Model
    url: => @get("url") or plunker.router.url("api") + "/plunks/" + @get('id')
    sync: sync
    defaults: ->
      description: ""
      files: {}
    
    initialize: ->
      self = @
      
      @changes = {}
      @on "sync", ->
        # Reset synced state and changes
        self.changes = {}
        self.synced = _.clone(self.attributes)
      
      # Handle simple changes
      _.each ["description", "index", "expires"], (key) ->
        self.on "change:#{key}", (model, value, options) ->
          self.changes[key] = value unless value == self.synced[key]
        
      # Handle changes to files
      @on "change:files", (model, value, options) ->
        previous = model.previous("files")
        changes = {}
        
        delete self.changes.files # Kill the old changes; the whole files hash changes
        
        for filename, file of previous
          unless _.isEqual(file, value[filename])
            changes[filename] = file
        
        self.changes.files = changes unless _.isEmpty(changes)
  
  class plunker.PlunkCollection extends Backbone.Collection
    url: => @get("url") or plunker.router.url("api") + "/plunks"
    model: plunker.Plunk
    comparator: (model) -> -Date.parse(model.get("updated_at") or model.get("created_at"))
    sync: sync
      
)(@plunker or @plunker = {})