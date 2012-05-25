#= require ../../vendor/jquery
#= require ../../vendor/underscore
#= require ../../vendor/backbone
#= require ../../vendor/handlebars

((plunker) ->
  

  class plunker.Operations extends Backbone.View  
    template: Handlebars.compile """
      {{#if plunk.token}}
        <li>
          <a class="edit" href="{{plunk.edit_url}}">
            <i class="icon-pencil" />
            Edit
          </a>
        </li>
        <li>
          <a class="delete">
            <i class="icon-trash" />
            Delete
          </a>
        </li>
      {{else}}
        <li>
          <a class="edit" href="{{plunk.edit_url}}">
            <i class="icon-pencil" />
            Fork
          </a>
      </li>

      {{/if}}
    """
      
    
    initialize: ->
      @model.on "change", @render
      
      @render()

    viewModel: ->
      user: plunker.user.toJSON()      
      plunk: _.defaults(@model.toJSON(),
        edit_url: plunker.router.url("www") + "/edit/#{@model.id}"
      )

    render: =>
      @$el.html @template(@viewModel())
      @
      
)(@plunker or @plunker = {})