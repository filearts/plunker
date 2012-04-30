#= require plunker

#= require ../bootstrap/js/bootstrap-all

#= require router

#= require models/plunks
#= require models/user

#= require views/userpanel

((plunker) ->

  $ ->
    plunker.user = new plunker.User
    plunker.login()

    plunker.views.userpanel = new plunker.UserPanel
      el: document.getElementById("userpanel")
      model: plunker.user

)(@plunker or @plunker = {})