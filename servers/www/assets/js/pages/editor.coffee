#= require ../plunker

#= require ../../bootstrap/js/bootstrap-all
#= require ../vendor/handlebars

#= require ../views/userpanel
#= require ../views/operations
#= require ../views/layout
#= require ../views/editarea
#= require ../views/sidebar
#= require ../views/statusbar


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
  
    plunker.views.layout = new plunker.BorderLayout
      el: document.getElementById("editor")
      
    plunker.views.editarea = new plunker.Editarea
    plunker.views.sidebar = new plunker.Sidebar
    plunker.views.statusbar = new plunker.Statusbar
      
    plunker.views.layout.attachPanel "center", plunker.views.statusbar, "append"
    plunker.views.layout.attachPanel "center", plunker.views.editarea, "append"
    plunker.views.layout.attachPanel "west", plunker.views.sidebar
    
    plunker.router.route "/edit/:id", (ctx) ->
  

    plunker.router.start()


)(@plunker or @plunker = {})