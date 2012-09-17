#= require ../vendor/jquery.cookie

#= require ../services/url

module = angular.module("plunker.plunks", ["plunker.url"])

module.factory "Plunk", ["$http", "$rootScope", "url", ($http, $rootScope, url) ->
  class window.Plunk
    @defaults:
      description: "Untitled"
      tags: []
      files:
        "index.html": {filename: "index.html", content: ""}
    @base_url: "#{url.api}/plunks"
    @query: (source, success = angular.noop, error = angular.noop) ->
      plunks = []
      params = sessid: $.cookie("plnk_session")
      
      unless angular.isObject(source)
        source = 
          url: source
          
      source.url ||= "#{url.api}/plunks"
      source.page and params.p = source.page
      source.size and params.pp = source.sizeji
      
      request = $http
        method: "GET"
        params: params
        url: source.url
      
      request.then (response) ->
        if link = response.headers("link")
          plunks.pager = {}
          
          link.replace /<([^>]+)>;\s*rel="(next|prev|first|last)"/gi, (match, href, rel) ->
            plunks.pager[rel] = href
        
        for plunk in response.data
          plunks.push new Plunk angular.extend plunk,
            html_url: "/#{plunk.id}"
            edit_url: "/edit/#{plunk.id}"
        
        success(plunks)
      , (error) ->
        console.log "Error", error
        
      plunks
      
    @get: (json, success = angular.noop, error = angular.noop) ->
      plunk = new Plunk(json)
      plunk.fetch(success, error)
      
    @create: (json, success = angular.noop, error = angular.noop) ->
      plunk = new Plunk(json)
      plunk.save(success, error)


    constructor: (attributes = {}) ->
      @reset(attributes)
      
      @description ||= "Untitled"
      @files ||= {}

      
    reset: (attributes = {}) -> angular.copy(attributes, @)
    
    getForkOf: ->
      if @fork_of
        if angular.isString(@fork_of)
          @fork_of = new Plunk(id: @fork_of)
        else unless @fork_of instanceof Plunk
          @fork_of = new Plunk(@fork_of)
        
        @fork_of.fetch() unless @fork_of.url
        @fork_of
    
    getForks: ->
      if @forks
        for fork, idx in @forks
          if angular.isString(fork)
            @forks[idx] = new Plunk(id: fork)
            @forks[idx].fetch()
          unless fork instanceof Plunk
            @forks[idx] = new Plunk(fork)
            @forks[idx].fetch() unless fork.url

        @forks
          
    getEditUrl: -> "/edit/#{@id}" if @id
    getHtmlUrl: -> "/#{@id}" if @id
    getCommentsUrl: -> @getHtmlUrl() + "/comments"
    
    isOwner: -> !@id or !!@token
    
    addThumbsUp: (success = angular.noop, error = angular.noop) ->
      plunk = @
      
      request = $http
        method: "POST"
        params: sessid: $.cookie("plnk_session")
        url: "#{url.api}/plunks/#{plunk.id}/thumb"
      
      request.then (response) ->
        plunk.thumbs = response.data.thumbs
        plunk.score = response.data.score
        
        plunk.thumbed = true
        
        success(plunk, response.headers)
      , error
    
      @      
    
    removeThumbsUp: (success = angular.noop, error = angular.noop) ->
      plunk = @
      
      request = $http
        method: "DELETE"
        params: sessid: $.cookie("plnk_session")
        url: "#{url.api}/plunks/#{plunk.id}/thumb"
      
      request.then (response) ->
        plunk.thumbs = response.data.thumbs
        plunk.score = response.data.score
        
        plunk.thumbed = false
        
        success(plunk, response.headers)
      , error
    
      @ 
    
    fetch: (success = angular.noop, error = angular.noop) ->
      plunk = @
      
      return @ unless plunk.id
      
      request = $http
        method: "GET"
        params: sessid: $.cookie("plnk_session")
        url: "#{url.api}/plunks/#{plunk.id}"
      
      request.then (response) ->
        angular.copy(response.data, plunk)
        
        success(plunk, response.headers)
      , error
    
      @
      
    destroy: (success = angular.noop, error = angular.noop) ->
      return error("Impossible to delete a plunk that is not saved") unless @id
      return error("Impossible to delete a plunk that you do not own") unless @token
      
      self = @
      
      path = "#{url.api}/plunks"
      path += "/#{self.id}" if self.id

      request = $http
        method: "DELETE"
        params: sessid: $.cookie("plnk_session")
        url: path
          
      request.then (response) ->
        angular.copy({}, self)
        success()
      , error
      
      self
  
    fork: (a0, a1, a2) ->
      self = @
      
      switch arguments.length
        when 3
          attributes = a0
          success = a1
          error = a2
        when 2
          success = a0
          error = a1
        when 1
          attributes = a0
        
      success ||= angular.noop
      error ||= angular.noop
      
      if self.id
        path = "#{url.api}/plunks/#{self.id}/forks"
        
        data = attributes or 
          description: self.description
          files: self.files
            
        request = $http
          method: "POST"
          params: sessid: $.cookie("plnk_session")
          url: path
          data: data
            
        request.then (response) ->
          #TODO: Hack around AngularJS 1.0.1 bug
          tags = self.tags
          
          angular.copy(response.data, self)
          
          if angular.equals(tags, self.tags)
            self.tags = tags # Reset tags to the old reference to avoid ngList bug
          
          success(self, response.headers)
        , error
      else
        error("Fork error: Plunk does not exist")
      
      self
    
    save: (a0, a1, a2) ->
      self = @
      
      switch arguments.length
        when 3
          attributes = a0
          success = a1
          error = a2
        when 2
          success = a0
          error = a1
        when 1
          attributes = a0
        
      success ||= angular.noop
      error ||= angular.noop
      
      path = "#{url.api}/plunks"
      path += "/#{self.id}" if self.id
      
      data = attributes or 
        description: self.description
        files: self.files
          
      request = $http
        method: "POST"
        params: sessid: $.cookie("plnk_session")
        url: path
        data: data
          
      request.then (response) ->
        #TODO: Hack around AngularJS 1.0.1 bug
        tags = self.tags
        
        angular.copy(response.data, self)
        
        if angular.equals(tags, self.tags)
          self.tags = tags # Reset tags to the old reference to avoid ngList bug
        
        success(self, response.headers)
      , error
      
      self
      
]