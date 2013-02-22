#= require ../../services/panels
#= require ../../services/scratch
#= require ../../services/url

debounce = (func, threshold, execAsap) ->
  timeout = false
  
  return debounced = ->
    obj = this
    args = arguments
    
    delayed = ->
      func.apply(obj, args) unless execAsap
      timeout = null
    
    if timeout
      clearTimeout(timeout)
    else if (execAsap)
      func.apply(obj, args)
    
    timeout = setTimeout delayed, threshold || 100

module = angular.module("plunker.panels")

module.run ["$http", "$timeout", "panels", "scratch", "url", ($http, $timeout, panels, scratch, url) ->
  panels.push new class
    name: "preview"
    order: 0
    title: "Preview your work in real-time"
    icon: "icon-eye-open"
    template: """
      <div class="plnk-previewer">
        <div id="preview-ops">
          <div class="btn-toolbar">
            <div class="btn-group" ng-switch on="windowed">
              <button id="refresh-preview" ng-click="refreshPreview()" class="btn btn-mini btn-success" title="Manually trigger a refresh of the preview"><i class="icon-refresh icon-white"></i></button>
              <button id="expand-preview" ng-click="expandWindow()" ng-switch-when="false" class="btn btn-mini btn-primary" title="Launch the preview in a separate window"><i class="icon-fullscreen icon-white"></i></button>
              <button id="expand-preview" ng-click="contractWindow()" ng-switch-when="true" class="btn btn-mini btn-danger" title="Close the child preview window"><i class="icon-remove icon-white"></i></button>
            </div>
          </div>
        </div>
        <iframe class="plnk-runner overthrow" frameborder="0" width="100%" height="100%" scrolling="auto"></iframe>
      </div>
    """
    watchChildWindow: ->
      self = @
      
      if self.windowed
        if self.childWindow is null or self.childWindow.closed
          # We are supposed to be in windowed mode, but the user closed the child window.
          # Switch back to normal mode
          self.scope.contractWindow()
        else
          # Keep watching while windowed
          $timeout angular.bind(self, self.watchChildWindow), 200
    
    refreshPreview: ->
      self = @
      json = { files: {} }
      
      for buffer in scratch.buffers.queue
        json.files[buffer.filename] =
          content: buffer.content
      
      unless self.windowed
        self.$preview.fadeOut("")
      
      request = $http.post("#{url.run}/#{@previewId}", json, cache: false)
      
      request.then (response) ->
        if self.windowed
          if self.childWindow is null or self.childWindow.closed
            self.childWindow = window.open response.data.run_url, "plnk_previewer", "resizable=yes,scrollbars=yes,status=yes"
          else
            self.childWindow.location.reload()
          self.watchChildWindow()
        else
          loc = self.$preview[0].contentWindow.location
          if loc is response.data.run_url
            loc.reload(true)
          else
            loc.replace(response.data.run_url)

          self.$preview.fadeIn(10).ready ->
            self.badge = null

        self.previewId = response.data.id
        
          
    link: ($scope, el, attrs) ->
      self = @
      @el = el
      @$preview = $(".plnk-runner", el)
      @active = false
      @awaiting = false
      
      @childWindow = null
      
      @previewId = ""
      
      @scope = $scope
      
      refresh = angular.bind(@, debounce(@refreshPreview, 750))
      
      $scope.scratch = scratch
      $scope.refreshPreview = refresh
      $scope.windowed = false
      
      setInterval
      
      $scope.expandWindow = ->
        $scope.windowed = self.windowed = true
        
        loc = self.$preview[0].contentWindow.location.replace("about:blank")
        
        self.refreshPreview()
      
      $scope.contractWindow = ->
        if self.windowed
          $scope.windowed = self.windowed = false
          self.childWindow?.close()
          
          self.refreshPreview()
      
      handleChange = ->
        if self.active
          self.awaiting = false
          refresh()
        else
          self.awaiting = true
          self.badge =
            class: "badge badge-important"
            title: "Click here to preview your changes"
            value: "*"
      
      $scope.$watch "scratch.id", ->
        @previewId = ""
      
      $scope.$on "buffer:change:content", handleChange
      $scope.$on "buffer:change:filename", handleChange
      $scope.$on "buffer:add", handleChange
      $scope.$on "buffer:remove", handleChange
      
    deactivate: ($scope, el, attrs) ->
      @active = false
      
      @$preview[0].contentWindow.location.replace("about:blank")

      @awaiting = true
      
    activate: ($scope, el, attrs) ->
      
      @active = true
      if @awaiting
        @refreshPreview()
        @awaiting = false
]