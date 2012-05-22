#= require ../../vendor/jquery
#= require ../../vendor/underscore
#= require ../../vendor/backbone
#= require ../../vendor/handlebars

((plunker) ->

  class plunker.Importer extends Backbone.View  
    events: =>
      "submit": "onSubmit"
    
    onSubmit: (e) ->
      e.preventDefault()
      self = @
      
      $input = @$("input.import-source").prop("disabled", true)
      $submit = @$("input.import-submit").prop("disabled", true)

      plunker.import @$(".import-source").val(), (err, json) ->
        $input.val("").prop("disabled", false)
        $submit.prop("disabled", false)
        
        if err or not json
          err ||= "Plunker could not import from that source"
          self.trigger "error", err.message or err
        else
          plunker.collections.plunks.create json,
            wait: true
            error: -> self.trigger "error", "Error creating plunk, please try again"
            success: ->
              console.log "SUCCESS", arguments...
              console.log "SELF", @

      
)(@plunker or @plunker = {})