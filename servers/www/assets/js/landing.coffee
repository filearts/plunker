#= require ../vendor/jquery
#= require ../vendor/underscore
#= require ../vendor/backbone

#= require ../bootstrap/js/bootstrap-all

#= require router

#= require models/plunks
#= require models/user

#= require views/userpanel

((plunker) ->
  _.extend plunker,
    mediator: _.extend {}, Backbone.Events
    models: {}
    collections: {}
    views: {}
    login: (auth) -> if plunker.user then plunker.user.onAuthSuccess(auth) else plunker.auth = auth
  
  # For debugging purposes
  plunker.mediator.on "all", -> console.log "[med]", arguments...
  
  $ ->
    plunker.user = new plunker.User
    plunker.user.fetch()

    plunker.views.userpanel = new plunker.UserPanel
      el: document.getElementById("userpanel")
      model: plunker.user
      
)(@plunker or @plunker = {})