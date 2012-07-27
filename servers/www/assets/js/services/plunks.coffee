#= require ../vendor/angular
#= require ../vendor/angular-cookies

#= require ../services/url

module = angular.module("plunker.plunks", ["ngCookies", "plunker.url"])

module.factory "Plunk", ["$http", "$rootScope", "$cookies", "url", ($http, $rootScope, $cookies, url) ->
  class window.Plunk
    @defaults:
      description: "Untitled"
      #tags: []
      files:
        "index.html": {filename: "index.html", content: ""}
    @base_url: "#{url.api}/plunks"
    @query: ->
      plunks = []
      
      request = $http
        method: "GET"
        url: "#{url.api}/plunks"
        headers:
          Authorization: "token #{$cookies.plnk_session}"
      
      request.then (response) ->
        for plunk in response.data
          plunks.push new Plunk angular.extend plunk,
            html_url: "/#{plunk.id}"
            edit_url: "/edit/#{plunk.id}"
      , (error) ->
        console.log "Error", error
        
      plunks
      
    @get: (json, success = angular.noop, error = angular.noop) ->
      plunk = new Plunk(json)
      plunk.fetch(success, error)
      
    @create: (json, success = angular.noop, error = angular.noop) ->
      plunk = new Plunk(json)
      
      request = $http
        method: "POST"
        url: "#{url.api}/plunks"
        data: plunk
        headers:
          Authorization: "token #{$cookies.plnk_session}"
          
      request.then (response) ->
        angular.copy(response.data, plunk)
        
        success(plunk, response.headers)
      , error
      
      plunk

    constructor: (attributes = {}) ->
      angular.copy(Plunk.defaults, @)
      angular.extend(@, attributes)
      
    fetch: (success = angular.noop, error = angular.noop) ->
      plunk = @
      
      request = $http
        method: "GET"
        url: "#{url.api}/plunks/#{plunk.id}"
        headers:
          Authorization: "token #{$cookies.plnk_session}"
      
      request.then (response) ->
        angular.copy(response.data, plunk)
        
        success(plunk, response.headers)
      , error
    
      @
    
    save: (attributes, success = angular.noop, error = angular.noop) ->
      self = @
      angular.extend(self, attributes) if attributes

      url = "#{url.api}/plunks"
      url += "/#{self.id}" if self.id
      
      data =
        description: self.description
        files: {}
      
      if self.id
        for filename, file of self.files
          data.files[filename] =
            content: file.content
          data.files[filename].filename = file.filename if filename != file.filename
      
      else
        data.source = self.source if self.source
      
        # Normalize filenames vs files for unsaved plunks
        old_files = data.files
        data.files = {}
        
        for filename, file of data.files
          data.files[file.filename] =
            content: file.content
          
      request = $http
        method: "POST"
        url: url
        data: data
        headers:
          Authorization: "token #{$cookies.plnk_session}"
          
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

module.factory "plunk", ["Plunk", (Plunk) -> new Plunk ]