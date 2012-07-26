#= require ../vendor/angular
#= require ../vendor/angular-cookies

#= require ../services/url

module = angular.module("plunker.plunks", ["ngCookies", "plunker.url"])

module.factory "Plunk", ["$http", "$rootScope", "$cookies", "url", ($http, $rootScope, $cookies, url) ->
  class window.Plunk
    @defaults:
      description: "Untitled"
      tags: []
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
      angular.copy(attributes, self) if attributes
      
      console.log "Self", @
      
      request = $http
        method: "POST"
        url: "#{url.api}/plunks"
        data: self
        headers:
          Authorization: "token #{$cookies.plnk_session}"
          
      request.then (response) ->
        angular.copy(response.data, self)
        
        success(self, response.headers)
      , error
      
      self
      
]

module.factory "plunk", ["Plunk", (Plunk) -> new Plunk ]