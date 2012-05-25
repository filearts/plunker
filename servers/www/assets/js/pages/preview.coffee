#= require ../plunker

#= require ../../bootstrap/js/bootstrap-all
#= require ../../vendor/handlebars
#= require ../../vendor/prettify

#= require ../lib/router

#= require ../models/user
#= require ../models/session
#= require ../models/plunks

#= require ../views/userpanel
#= require ../views/operations


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
      $("#pages").attr("class", page)
      $(".nav .active").removeClass("active")
      $(".nav .#{page}").addClass("active")
    
    plunker.router.route "*other", "blank", (page) ->
      if page is "preview" or (not page)
        changePageTo("preview")
        $("#preview-frame").attr("src", plunker.models.plunk.get("raw_url"))
      else
        changePageTo("code")
        $("#preview-frame").attr("src", "")
        
    plunker.user.on "change:id", ->
      plunker.models.plunk.fetch
        # This annoying code is brought to you by Backbone.js issue #955
        success: (model, json) ->
          for key, val of plunker.models.plunk.attributes
            plunker.models.plunk.unset(key) unless json[key]
    
    plunker.views.userpanel = new plunker.UserPanel
      el: document.getElementById("userpanel")
      model: plunker.user
      
    plunker.views.operations = new plunker.Operations
      el: document.getElementById("operations")
      model: plunker.models.plunk

    Backbone.history.start()
    
    prettyPrint()


)(@plunker or @plunker = {})