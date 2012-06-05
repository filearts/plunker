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
      
    events:
      "click .edit": "onClickEdit"
      "click .delete": "onClickDelete"
    
    initialize: ->
      @model.on "change", @render
      @model.on "destroy", ->
        window.location = plunker.router.url("www")
      
      @render()
    
    onClickEdit: (e) =>
      
    onClickDelete: (e) =>
      @model.destroy(wait: true) if confirm "Are you sure that you would like to delete this plunk?"

    viewModel: ->
      user: plunker.user.toJSON()      
      plunk: _.defaults(@model.toJSON(),
        edit_url: plunker.router.url("www") + "/edit/#{@model.id}"
      )

    render: =>
      @$el.html @template(@viewModel())
      @
      
)(@plunker or @plunker = {})