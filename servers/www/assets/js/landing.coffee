#= require ../vendor/jquery
#= require ../vendor/underscore
#= require ../vendor/backbone


#= require router
#= require models/plunks
#= require models/user

((plunker) ->
  _.extend plunker,
    user: new plunker.User
    mediator: _.extend {}, Backbone.Events
    models: {}
    collections: {}
    views: {}
  
      
)(@plunker or @plunker = {})