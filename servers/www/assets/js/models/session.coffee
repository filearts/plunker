((plunker) ->
  
  
  class GithubAuthProvider
    constructor: ->
      self = @
      
      _.extend @, Backbone.Events
      
      plunker.mediator.on "intent:auth", (service) -> if service is "github" then self.showLoginWindow()
      plunker.mediator.on "event:auth", (json) -> self.trigger("authorized", json) if json.service is "github"
      plunker.mediator.on "error:auth", (json) -> self.trigger("denied", json) if json.service is "github"
        
    showLoginWindow: (width = 1000, height = 650) ->
      screenHeight = screen.height
      left = Math.round((screen.width / 2) - (width / 2))
      top = 0
      if (screenHeight > height)
          top = Math.round((screenHeight / 2) - (height / 2))
          
      debugger

      login = window.open "/auth/github", "Sign in with Github", """
        left=#{left},top=#{top},width=#{width},height=#{height},personalbar=0,toolbar=0,scrollbars=1,resizable=1
      """
      
      debugger

      winCloseCheck = ->
        return if login && !login.closed
        clearInterval(winListener)

      winListener = setInterval(winCloseCheck, 1000)

      if login then login.focus()


  class plunker.Session extends Backbone.Model
    url: -> @get("url") or plunker.router.url("api") + "/sessions"
    initialize: ->
      self = @
      
      @github = new GithubAuthProvider
      @github.on "authorized", (json) -> self.upgrade("github", json)
      
      plunker.mediator.on "intent:logout", ->
        self.downgrade()
      
      @on "change:id", (model, value, options) ->
        if value then $.cookie "plnk_session", value, expires: 7, path: "/"
        else $.cookie "plnk_session", null
    
    fetch: ->
      self = @
      plunker.request "/session",
        success: (json) -> self.start(json)
        error: (err) -> plunker.mediator.trigger "error", err
    
    start: (json) ->
      if json and json.user
        user = json.user
        delete json.user
        
      @clear(silent: !json).set(json)
      
      plunker.user.clear()
      plunker.user.set(user) if user
      
      @
    
    upgrade: (service, json) ->
      self = @
      if @id then plunker.request
        url: @get("user_url")
        type: "post"
        data: { service: service, token: json.token }
        dataType: "json"
        success: (json) -> self.start(json)
    
    downgrade: (service, json) ->
      self = @
      if @id then plunker.request
        url: @get("user_url")
        type: "delete"
        success: (json) -> self.start(json)



)(@plunker or @plunker = {})