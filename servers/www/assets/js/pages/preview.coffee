#= require ../plunker

#= require ../../bootstrap/js/bootstrap-all
#= require ../vendor/handlebars
#= require ../vendor/prettify

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
    $preview = $("<iframe></iframe>")
      .attr("id", "preview-frame")
      .attr("frameborder", "0")
      .attr("height", "100%")
      .attr("width", "100%")
      .attr("src", plunker.models.plunk.get("raw_url"))
      
    changePageTo = (page) ->
      $("#pages").attr("class", page)
      $(".nav .active").removeClass("active")
      $(".nav .#{page}").addClass("active")
      
    plunker.router.route "/:id", (ctx) ->
      changePageTo("preview")
      
      $preview.appendTo("#preview")
    
    plunker.router.route "/:id/code", (ctx) ->
      changePageTo("code")
      
      $preview.detach()
      
    
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
      
    if plunk = plunker.models.plunk
      presenceRef = new Firebase("http://gamma.firebase.com/filearts/#{plunk.id}/viewers")

      setOwnStatus = ->
        ownStatusRef.removeOnDisconnect()
        ownStatusRef.set plunker.user.get("login") or "Anonymous"
      
      ownStatusRef = presenceRef.child(plunker.session.get("public_id"))
      ownStatusRef.on "value", (snapshot) ->
        setOwnStatus() if snapshot.val() is null

  
    plunker.router.start()
    
    prettyPrint()


)(@plunker or @plunker = {})