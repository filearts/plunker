#= require ../vendor/jquery
#= require ../vendor/underscore
#= require ../vendor/backbone


((plunker) ->
  _.extend plunker,
    mediator: _.extend {}, Backbone.Events
    models: {}
    collections: {}
    views: {}
    request: (path, options = {}) ->
      if _.isObject(path) and _.isEmpty(options) then options = path
      $.ajax _.defaults options,
        url: plunker.router.url("api") + path
        dataType: "json"
        xhrFields: { withCredentials: true }
        beforeSend: (xhr) -> xhr.withCredentials = true
    login: (auth) ->
      if auth then plunker.auth = auth
      if plunker.user and plunker.auth then plunker.user.onAuthSuccess(plunker.auth)

  # For debugging purposes
  plunker.mediator.on "all", -> console.log "[med]", arguments...

)(@plunker or @plunker = {})