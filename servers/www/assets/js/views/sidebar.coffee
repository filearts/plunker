#= require ../vendor/jquery
#= require ../vendor/underscore
#= require ../vendor/backbone
#= require ../vendor/handlebars
#= require ../vendor/ace/ace

#= require ../lib/panel

((plunker) ->
  
  class plunker.Sidebar extends plunker.Panel
    template: Handlebars.compile """
      <ul class="nav nav-list">
        <li class="nav-header">
          Files
        </li>
        <li class="active">
          <a href="#index_html">index.html</a>
        </li>
        <li>
          <a href="#style_css">style.css</a>
        </li>
        <li>
          <a href="#script_coffee">script.coffee</a>
        </li>
      </ul>
    """
    
    initialize: ->
      @render()
      
    viewModel: -> {}

    render: =>
      @$el.html @template(@viewModel())
      @
            
)(@plunker or @plunker = {})