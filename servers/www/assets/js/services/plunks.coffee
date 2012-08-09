#= require ../vendor/angular
#= require ../vendor/jquery.cookie

#= require ../services/url

module = angular.module("plunker.plunks", ["plunker.url"])

module.factory "Plunk", ["$http", "$rootScope", "url", ($http, $rootScope, url) ->
  class window.Plunk
    @defaults:
      description: "Untitled"
      #tags: []
      files:
        "index.html": {filename: "index.html", content: ""}
    @base_url: "#{url.api}/plunks"
    @query: (source, success = angular.noop, error = angular.noop) ->
      plunks = []
      
      unless angular.isObject(source)
        source = 
          url: source
          
      source.url ||= "#{url.api}/plunks"
      source.url += "?p=#{source.page}&pp=#{source.size}" if source.page and source.size
      
      request = $http
        method: "GET"
        url: source.url
        headers:
          Authorization: "token " + $.cookie("plnk_session")
      
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
      @description = ""
      @files = {}
      angular.extend(@, attributes)
      
    reset: (attributes = {}) -> angular.copy(attributes, @)
      
    isOwner: -> !@id or !!@token
    
    fetch: (success = angular.noop, error = angular.noop) ->
      plunk = @
      
      request = $http
        method: "GET"
        url: "#{url.api}/plunks/#{plunk.id}"
        headers:
          Authorization: "token " + $.cookie("plnk_session")
      
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
        url: path
        headers:
          Authorization: "token " + $.cookie("plnk_session")
          
      request.then (response) ->
        angular.copy({}, self)
        success()
      , error
      
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
      path += "/forks" unless self.isOwner()
      
      data = attributes or 
        description: self.description
        files: self.files
          
      request = $http
        method: "POST"
        url: path
        data: data
        headers:
          Authorization: "token " + $.cookie("plnk_session")
          
      request.then (response) ->
        angular.copy(response.data, self)
        
        success(self, response.headers)
      , error
      
      self
      
]