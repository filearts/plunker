#= require ../vendor/jquery
#= require ../vendor/jquery.cookie
#= require ../vendor/underscore
#= require ../vendor/backbone

#= require models/user
#= require models/session

((plunker) ->
  _.extend plunker,
    mediator: _.extend {}, Backbone.Events
    models: {}
    collections: {}
    views: {}
    request: (path, options = {}) ->
      if _.isObject(path) and _.isEmpty(options)
        options = path
        path = ""
      
      if _.isObject(options.data) then options.data = JSON.stringify(options.data)
      
      $.ajax _.defaults options,
        url: plunker.router.url("api") + path
        dataType: "json"
        #xhrFields: { withCredentials: true }
        error: (xhr, status, text) -> plunker.mediator.trigger "error", arguments...
        beforeSend: (xhr) ->
          xhr.setRequestHeader("Authorization", "token #{token}") if token = $.cookie("plnk_session")
          xhr.setRequestHeader("Content-Type", "application/json")
          #xhr.withCredentials = true # No longer needed *sigh*
  
  plunker.user = new plunker.User
  plunker.session = new plunker.Session

  # For debugging purposes
  plunker.mediator.on "all", -> console.log "[med]", arguments...

)(@plunker or @plunker = {})