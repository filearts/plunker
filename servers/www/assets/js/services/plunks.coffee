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
      angular.copy(Plunk.defaults, @)
      angular.extend(@, attributes)
      
    isOwner: -> if @id then !!@token else true
    
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
        angular.copy(Plunk.defaults, self)
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
      
      angular.extend(self, attributes) if attributes

      path = "#{url.api}/plunks"
      path += "/#{self.id}" if self.id
      path += "/forks" unless self.isOwner()
      
      data =
        description: self.description
        files: {}
      
      if self.id and self.isOwner()
        for filename, file of self.files
          if file
            data.files[filename] =
              content: file.content
            data.files[filename].filename = file.filename if filename != file.filename
          else
            data.files[filename] = null
      
      else
        data.source = self.source if self.source
      
        # Normalize filenames vs files for unsaved plunks
        for filename, file of self.files
          # Skip files that are set to null
          if file
            data.files[file.filename] =
              content: file.content
          else
            delete self.files[filename]
          
      request = $http
        method: "POST"
        url: path
        data: data
        headers:
          Authorization: "token " + $.cookie("plnk_session")
          
      request.then (response) ->
        data = angular.copy(response.data) # Is this copy needed?
        
        self.comments = data.comments
        self.comments_url = data.comments_url
        self.created_at = data.created_at
        self.description = data.description
        
        unless self.id = data.id then delete self.id
        
        self.id = data.id if data.id
        self.raw_url = data.raw_url
        
        unless self.token = data.token then delete self.token
        
        self.updated_at = data.updated_at
        self.url = data.url
        
        unless self.user = data.user then delete self.user
        
        old_files = self.files

        for filename, file of old_files
          if file is null
            if data.files[filename] then throw new Error("Data inconsistency; #{filename} marked for deletion but still present")
            else delete self.files[filename]
          else if filename != file.filename
            # OK; file exists under new name
            if new_file = data.files[file.filename]
              angular.copy(new_file, file)
              self.files[file.filename] = file
              delete self.files[filename]
            else throw new Error("Data inconsistency; #{filename} renamed to #{file.filename} but not returned by server")
          else
            if new_file = data.files[file.filename]
              angular.extend(self.files[file.filename], new_file)
            else throw new Error("Data inconsistency; #{filename} exists butwas not returned by server")
        
        success(self, response.headers)
      , error
      
      self
      
]