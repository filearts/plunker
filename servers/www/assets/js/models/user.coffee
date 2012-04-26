((plunker) ->
  
  class Auth extends Backbone.Model
  
  class AuthCollection extends Backbone.Collection
    model: Auth

  class plunker.User extends Backbone.Model
    initialize: ->
      self = @
      
      @auths = new AuthCollection
      
      plunker.mediator.on "event:auth", (auth) ->
        $.ajax
          url: plunker.router.url("api") + "/auths/github"
          data: { token: auth.token }
          success: self.onAuthSuccess
          error: self.onAuthError
      
      plunker.mediator.on "intent:logout", ->
        $.ajax 
          url: plunker.router.url("api") + "/auth"
          type: "DELETE"
          success: -> self.logout()
          error: -> plunker.mediator.trigger "error",
            title: "Error logging out"
            body: """
              <p>There was an error while attempting to log out. Please try again.</p>
              <p>If the problem persists, please <a href="https://github.com/filearts/plunker/issues/new">file a bug report</a>.</p>
            """
      
      # Try to login based on cookie
      # @fetch()
    
    onAuthSuccess: (json) =>
      @token = json.id
      
      @auths.add
        id: json.service
        token: json.service_token
        user: json.user
      
      @login json.user
    
    onAuthError: (json) =>
      plunker.mediator.trigger "error:login", arguments...
      
    fetch: ->
      self = @
      
      $.ajax plunker.router.url("api") + "/auth",
        success: @onAuthSuccess
    
    
    login: (json) ->
      @clear(silent: true).set(json)
      plunker.mediator.trigger "event:login", @
    
    logout: ->
      @clear()
      plunker.mediator.trigger "event:logout"
    
    showLoginWindow: (width = 1000, height = 650) ->
      screenHeight = screen.height
      left = Math.round((screen.width / 2) - (width / 2))
      top = 0
      if (screenHeight > height)
          top = Math.round((screenHeight / 2) - (height / 2))
      
      login = window.open "/auth/github", "Sign in with Github", """
        left=#{left},top=#{top},width=#{width},height=#{height},personalbar=0,toolbar=0,scrollbars=1,resizable=1
      """
      
      winCloseCheck = ->
        return if login && !login.closed
        clearInterval(winListener)

      winListener = setInterval(winCloseCheck, 1000)
      
      if login then login.focus()      
      
      
)(@plunker or @plunker = {})