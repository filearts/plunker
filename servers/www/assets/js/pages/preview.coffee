#= require ../plunker

#= require ../../bootstrap/js/bootstrap-all
#= require ../../vendor/handlebars

#= require ../lib/router

#= require ../models/user
#= require ../models/session

#= require ../views/userpanel


Handlebars.registerHelper "or", (arg1, arg2) -> arg1 or arg2

Handlebars.registerHelper "dateToLocaleString", (updated_at, created_at) ->
  new Date(Date.parse(updated_at or created_at)).toLocaleString()
  
Handlebars.registerHelper "dateToTimestamp", (updated_at, created_at) ->
  Date.parse(updated_at or created_at)

Handlebars.registerHelper "arrayJoinSpace", (array) ->
  array.join(" ")

((plunker) ->

  $ ->

    plunker.views.userpanel = new plunker.UserPanel
      el: document.getElementById("userpanel")
      model: plunker.user

)(@plunker or @plunker = {})