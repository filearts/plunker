#= require ../plunker

#= require ../../bootstrap/js/bootstrap-all
#= require ../../vendor/handlebars

#= require ../lib/importer

#= require ../models/sections
#= require ../models/plunks

#= require ../views/navbar
#= require ../views/userpanel
#= require ../views/importer
#= require ../views/gallery

Handlebars.registerHelper "or", (arg1, arg2) -> arg1 or arg2

Handlebars.registerHelper "dateToLocaleString", (updated_at, created_at) ->
  new Date(Date.parse(updated_at or created_at)).toLocaleString()
  
Handlebars.registerHelper "dateToTimestamp", (updated_at, created_at) ->
  Date.parse(updated_at or created_at)

Handlebars.registerHelper "arrayJoinSpace", (array) ->
  array.join(" ")

((plunker) ->

  $ ->
    plunker.collections.sections = new plunker.Sections
    plunker.collections.plunks = new plunker.PlunkCollection

    plunker.views.navbar = new plunker.Navbar
      el: document.getElementById("navbar")
      collection: plunker.collections.sections

    plunker.views.userpanel = new plunker.UserPanel
      el: document.getElementById("userpanel")
      model: plunker.user
    
    plunker.views.importer = new plunker.Importer
      el: document.getElementById("importer")
    
    plunker.views.gallery = new plunker.Gallery
      el: document.getElementById("gallery")
      collection: plunker.collections.plunks
      
    plunker.collections.sections.add
      title: "Home"
      url: "/"
      icon: "icon-home"
    plunker.collections.sections.add
      title: "Browse"
      url: "/browse"
      icon: "icon-th"
    plunker.collections.sections.add
      title: "About"
      url: "/about"
      icon: "icon-info-sign"
      
      
    
    plunker.collections.plunks.fetch()
    

)(@plunker or @plunker = {})