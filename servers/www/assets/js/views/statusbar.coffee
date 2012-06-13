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
                index.html
                <b class="caret"></b>
              </a>
              
              <ul id="editor-file-list" class="dropdown-menu">
                <li class="add">
                  <a href="javascript:void(0)">Add file...</a>
                </li>
                <li class="divider"></li>
                <li class="active"><a>index.html</a></li>
                <li><a>style.css</a></li>
              </ul>
            </li>
            <li class="divider-vertical"></li>
          </ul>
        </div>
      </div>
    """
    
    initialize: ->
      @render()
      
    viewModel: -> {}

    render: =>
      @$el.html @template(@viewModel())
      @
      
)(@plunker or @plunker = {})