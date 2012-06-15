#= require ../vendor/jquery
#= require ../vendor/underscore
#= require ../vendor/backbone
#= require ../vendor/handlebars

#= require ../lib/panel

((plunker) ->
  
  class plunker.Statusbar extends plunker.Panel
    className: "editor-status"
    template: Handlebars.compile """
      <div class="navbar navbar-fixed-bottom">
        <div class="navbar-inner">
          <ul class="nav">
            <li class="dropdown">
              <a href="javascript:void(0)" class="dropdown-toggle" data-toggle="dropdown">
                {{active}}
                <b class="caret"></b>
              </a>
              
              <ul id="editor-file-list" class="dropdown-menu">
                <li class="file-add">
                  <a href="javascript:void(0)">Add file...</a>
                </li>
                <li class="divider"></li>
                {{#each buffers}}
                  {{#if this.active}}
                    <li class="buffer active">
                      <a href="\#{{slugify this.filename}}">{{this.filename}}</a>
                    </li>
                  {{else}}
                    <li class="buffer">
                      <a href="\#{{slugify this.filename}}">{{this.filename}}</a>
                    </li>
                  {{/if}}
                {{/each}}
              </ul>
            </li>
            <li class="divider-vertical"></li>
          </ul>
        </div>
      </div>
    """
    
    events:
      "click .buffer": "onClickBuffer"
      "click .file-add": -> plunker.mediator.trigger "prompt:file:add"
    
    initialize: ->
      self = @
      
      @model.buffers.on "reset add remove", @render
      @model.on "change:active", @render
      
      @render = _.throttle(@render, 100)
      @render()
      
    onClickBuffer: (e) ->
      plunker.mediator.trigger "intent:file:activate", $(e.target).text()
      
    viewModel: ->
      buffers: @model.buffers.toJSON()
      active: @model.get("active")

    render: =>
      @$el.html @template(@viewModel())
      @
      
)(@plunker or @plunker = {})