#= require ../../vendor/jquery
#= require ../../vendor/angular

#= require ../../services/panels
#= require ../../services/scratch
#= require ../../services/url

debounce = (func, wait, immediate) ->
  timeout = undefined
  ->
    context = @
    args = arguments
    later = ->
      timeout = null
      unless immediate then func.apply(context, args)
    if immediate and not timeout then func.apply(context, args)
    clearTimeout(timeout)
    timeout = setTimeout(later, wait)


module = angular.module("plunker.panels")

module.run ["$http", "panels", "scratch", "url", ($http, panels, scratch, url) ->
  panels.push new class
    name: "preview"
    order: 0
    title: "Show/hide the live preview pane"
    icon: "icon-eye-open"
    template: """
      <div class="plnk-previewer">
        <div id="preview-ops">
          <div class="btn-toolbar">
            <div class="btn-group">
              <button id="refresh-preview" ng-click="refreshPreview()" class="btn btn-mini btn-success"><i class="icon-refresh icon-white"></i></button>
            </div>
          </div>
        </div>
      </div>
    """
    refreshPreview: ->
      self = @
      json = { files: {} }
      
      for file in scratch.getValidFiles()
        json.files[file.filename] =
          content: file.content
      
      request = $http.post("#{url.api}/previews", json)
      
      request.then (response) ->
        $old = self.$preview
        self.$preview = $("<iframe>", src: response.data.run_url, class: "plnk-runner", frameborder: 0, width: "100%", height: "100%", scrolling: "auto").appendTo(self.el)
        self.$preview.ready ->
          if $old then $old.fadeOut -> $old.remove()
          self.$preview.fadeIn()
          
          self.badge = null
    , 1000
          
    link: ($scope, el, attrs) ->
      self = @
      @el = el
      @$preview = null
      @enabled = false
      @awaiting = false
      
      refresh = angular.bind(@, debounce(@refreshPreview, 1000))
      
      $scope.scratch = scratch
      $scope.refreshPreview = refresh
      
      $scope.$watch "scratch.plunk.files", (files) ->
        if self.enabled
          self.awaiting = false
          refresh()
        else
          self.awaiting = true
          self.badge =
            class: "badge badge-important"
            title: "Click here to preview your changes"
            value: "*"
          
      , true
      
    deactivate: ($scope, el, attrs) ->
      @enabled = false
      
    activate: ($scope, el, attrs) ->
      
      @enabled = true
      if @awaiting
        @refreshPreview()
        @awaiting = false
]