#= require ../vendor/angular
#= require ../vendor/angular-resource

#= require ../services/url

module = angular.module("plunker.plunks", ["ngResource", "plunker.url"])

module.factory "Plunk", ($resource, $http, url) ->
  onSuccess = -> console.log "onSuccess", arguments...
  onError = -> console.log "onError", arguments...
  
  class Plunk
    @base_url: "#{url.api}/plunks"
    @query: ->
      plunks = []
      
      $http.get("#{url.api}/plunks").then (response) ->
        plunks = []
        
        for plunk in response.data
          plunks.push new Plunk angular.extend plunk,
            html_url: "/#{plunk.id}"
            edit_url: "/edit/#{plunk.id}"
        
        console.log "Plunks", plunks
        
        plunks
      , (error) ->
        console.log "Error", error
      
      plunks

    constructor: (attributes) ->
      angular.copy attributes, @