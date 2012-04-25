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
  
  # For debugging purposes
  plunker.mediator.on "all", -> console.log "[med]", arguments...
  
  $ ->
    plunker.user = new plunker.User

    plunker.views.userpanel = new plunker.UserPanel
      el: document.getElementById("userpanel")
      model: plunker.user
      
)(@plunker or @plunker = {})