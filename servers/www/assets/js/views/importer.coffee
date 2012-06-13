#= require ../vendor/jquery
#= require ../vendor/underscore
#= require ../vendor/backbone
#= require ../vendor/handlebars

((plunker) ->

  messageTemplate = Handlebars.compile """
    <div class="alert alert-block fade in {{class}}">
      <a href="javascript:void(0)" class="close" data-dismiss="alert">×</a>
      <h4 class="alert-heading">{{title}}</h4>
      {{message}}
    </div>
  """
  
  showError = (title, message) ->
    $("#importer").append $ messageTemplate
      title: title
      message: message
      class: "alert-error"

  class plunker.Importer extends Backbone.View
    initialize: ->
      @on "import", (plunk) -> window.location = plunk.getPreviewUrl()
      @on "error", (message) ->
        $("#importer").after $ messageTemplate
          title: "Import failed: #{message}"
          message: """
            Please check the value that you entered and try again.
            If this problem persists, please contact an administrator.
          """
          class: "alert-error"
      
    events:
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
          err ||= "That is not a recognized source"
          self.trigger "error", err.message or err
        else
          plunker.collections.plunks.create json,
            wait: true
            error: -> self.trigger "error", "Error creating plunk, please try again"
            success: (plunk) -> self.trigger "import", plunk

      
)(@plunker or @plunker = {})