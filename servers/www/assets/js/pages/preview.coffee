#= require ../plunker

#= require ../../bootstrap/js/bootstrap-all
#= require ../../vendor/handlebars
#= require ../../vendor/prettify

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
    
    changePageTo = (page) ->
      ->
        $("#pages").attr("class", page)
        $(".nav .active").removeClass("active")
        $(".nav .#{page}").addClass("active")
    
    plunker.router.route "preview", "preview", changePageTo("preview")
    plunker.router.route "*filename", "code", changePageTo("code")
    plunker.router.route "", "blank", ->
      if page = $("#pages").attr("class")
        $(".nav .active").removeClass("active")
        $(".nav .#{page}").addClass("active")
      else
        plunker.router.navigate "code",
          trigger: true
          replace: true
    
    plunker.views.userpanel = new plunker.UserPanel
      el: document.getElementById("userpanel")
      model: plunker.user

    Backbone.history.start()
    
    prettyPrint()

)(@plunker or @plunker = {})