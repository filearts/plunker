#= require ../plunker

#= require ../../bootstrap/js/bootstrap-all
#= require ../vendor/handlebars

#= require ../models/creation

#= require ../views/userpanel
#= require ../views/operations
#= require ../views/layout
#= require ../views/editarea
#= require ../views/sidebar
#= require ../views/statusbar
#= require ../views/actionbar
#= require ../views/overlay


Handlebars.registerHelper "or", (arg1, arg2) -> arg1 or arg2

Handlebars.registerHelper "dateToLocaleString", (updated_at, created_at) ->
  new Date(Date.parse(updated_at or created_at)).toLocaleString()
  
Handlebars.registerHelper "dateToTimestamp", (updated_at, created_at) ->
  Date.parse(updated_at or created_at)

Handlebars.registerHelper "arrayJoinSpace", (array) ->
  array.join(" ")

Handlebars.registerHelper "slugify", (str) ->
  str.replace(/[\.]/g, "_")

((plunker) ->

  $ ->
    
    plunker.models.creation = new plunker.Creation
      
    plunker.views.userpanel = new plunker.UserPanel
      el: document.getElementById("userpanel")
      model: plunker.user
  
    plunker.views.layout = new plunker.BorderLayout
      el: document.getElementById("editor")
      
    plunker.views.editarea = new plunker.Editarea
      model: plunker.models.creation
      
    plunker.views.sidebar = new plunker.Sidebar
      model: plunker.models.creation
    
    plunker.views.actionbar = new plunker.Actionbar
      el: document.getElementById("actionbar")
      model: plunker.models.creation

    plunker.views.statusbar = new plunker.Statusbar
      model: plunker.models.creation
      
    plunker.views.overlay = new plunker.Overlay
      el: document.getElementById("editor")
      enableEvents: ["editor:enable"]
      disableEvents: ["editor:disable"]
      
    plunker.views.layout.attachPanel "center", plunker.views.editarea, "append"
    plunker.views.layout.attachPanel "center", plunker.views.statusbar, "append"
    plunker.views.layout.attachPanel "west", plunker.views.sidebar
    
    plunker.router.route "/edit/from::id", (ctx, next) ->
      console.log "routed", ":/edit/from::id"
      plunker.models.creation.import ctx.params.id,
        error: -> plunker.router.navigate("/edit/")

    plunker.router.route "/edit/:id", (ctx, next) ->
      console.log "routed", ":/edit/:id"
      plunker.models.creation.load ctx.params.id,
        error: -> plunker.router.navigate("/edit/")

    plunker.router.route "/edit/", (ctx, next) ->
      console.log "routed", ":/edit/"
      plunker.models.creation.import("2312729")

    plunker.router.start()


)(@plunker or @plunker = {})