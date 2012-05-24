#= require ../plunker

#= require ../../bootstrap/js/bootstrap-all
#= require ../../vendor/handlebars
#= require ../../vendor/jquery.autoheight


#= require ../lib/router


Handlebars.registerHelper "or", (arg1, arg2) -> arg1 or arg2

Handlebars.registerHelper "dateToLocaleString", (updated_at, created_at) ->
  new Date(Date.parse(updated_at or created_at)).toLocaleString()
  
Handlebars.registerHelper "dateToTimestamp", (updated_at, created_at) ->
  Date.parse(updated_at or created_at)

Handlebars.registerHelper "arrayJoinSpace", (array) ->
  array.join(" ")

((plunker) ->

  $ ->
    $("#preview-frame").iframeAutoHeight();

)(@plunker or @plunker = {})