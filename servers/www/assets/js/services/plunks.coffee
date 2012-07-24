#= require ../vendor/angular
#= require ../vendor/angular-cookies

#= require ../services/url

module = angular.module("plunker.plunks", ["ngCookies", "plunker.url"])

module.factory "Plunk", ["$http", "$rootScope", "$cookies", "url", ($http, $rootScope, $cookies, url) ->
  class Plunk
    @defaults:
      description: "Untitled"
      tags: []
      files: {}
    @base_url: "#{url.api}/plunks"
    @query: ->
      plunks = []
      
      dfd = $http
        method: "GET"
        url: "#{url.api}/plunks"
        headers:
          Authorization: "token #{$cookies.plnk_session}"
      
      $http.get("#{url.api}/plunks").then (response) ->
        for plunk in response.data
          plunks.push new Plunk angular.extend plunk,
            html_url: "/#{plunk.id}"
            edit_url: "/edit/#{plunk.id}"
      , (error) ->
        console.log "Error", error
        
      plunks
    
    @create: (json) ->
      $http.post("#{url.api}/plunks", json).then (response) ->
        console.log "Response", response

    constructor: (attributes) ->
      window.Plunk = Plunk
      angular.extend @, angular.copy(Plunk.defaults), angular.copy(attributes)
]