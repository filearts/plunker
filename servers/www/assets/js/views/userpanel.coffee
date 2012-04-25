#= require ../../vendor/jquery
#= require ../../vendor/underscore
#= require ../../vendor/backbone
#= require ../../vendor/handlebars

((plunker) ->
  
  class plunker.UserPanel extends Backbone.View
    template: Handlebars.compile """
      <div class="btn-group">
        {{#if user.id}}
          <button class="btn dropdown-toggle" data-toggle="dropdown">
            <img class="gravatar" src="http://www.gravatar.com/avatar/{{user.gravatar_id}}?s=20" />
            {{user.login}}
            <i class="icon-github-sign" />
            <b class="caret" />
          </button>
          <ul class="dropdown-menu">
            <li>
              <a class="logout" href="/logout">Logout</a>
            </li>
          </ul>
        {{else}}
          <button class="btn dropdown-toggle" data-toggle="dropdown">
            <i class="icon-user" />
            <span class="text">Sign in</span>
            <span class="caret"></span>
          </button>
          <ul class="dropdown-menu">
            <li>
              <a class="login login-github" data-service="github" href="/auth/github">
                <i class="icon-github-sign" />
                Sign in with Github
              </a>
            </li>
          </ul>
        {{/if}}
      </div>
    """

    events:
      "click .login": (e) ->
        e.preventDefault()
        @showLoginWindow()
        
      "click .logout": (e) ->
        e.preventDefault()
        plunker.mediator.trigger "intent:logout"
      
    
    initialize: ->
      @model.on "change", @render
      
      @render = _.throttle(@render, 500)() # Call it once right away

    showLoginWindow: (width = 1000, height = 650) ->
      screenHeight = screen.height
      left = Math.round((screen.width / 2) - (width / 2))
      top = 0
      if (screenHeight > height)
          top = Math.round((screenHeight / 2) - (height / 2))
      
      login = window.open "/auth/github", "Sign in with Github", """
        left=#{left},top=#{top},width=#{width},height=#{height},scrollbars=1,resizable=1
      """
      
      winCloseCheck = ->
        return if login && !login.closed
        clearInterval(winListener)

      winListener = setInterval(winCloseCheck, 1000)
      
      if login then login.focus();

    render: =>
      @$el.html @template
        user: @model.toJSON()
      @
      
)(@plunker or @plunker = {})