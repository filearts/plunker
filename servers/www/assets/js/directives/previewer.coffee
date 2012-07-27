#= require ../vendor/jquery
#= require ../vendor/angular

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


module = angular.module("plunker.previewer", ["plunker.url"])

module.directive "plunkerPreviewer", ["$http", "url", ($http, url) ->
  restrict: "A"
  link: ($scope, el, attrs) ->
    $preview = null
    enabled = true
    deferred = false
    
    $scope.refreshPreview = (files) ->
      unless enabled
        deferred = $scope.refreshPreview.bind(@, files)
      else
        json = { files: {} }
        
        for filename, file of files
          json.files[file.filename] =
            content: file.content
        
        request = $http.post("#{url.api}/previews", json)
        
        request.then (response) ->
          $old = $preview
          $preview = $("<iframe>", src: response.data.run_url, class: "plnk-runner", frameborder: 0, width: "100%", height: "100%", scrolling: "auto").appendTo(el)
          $preview.ready ->
            if $old then $old.fadeOut -> $old.remove()
            $preview.fadeIn()
        
    $scope.$watch "layout.state.east.isClosed", (closed) ->
      enabled = !closed
      
      if closed
        $preview.remove() if $preview
      else if deferred
        deferred() if deferred
        deferred = false
    
    $scope.$watch "plunk.files", debounce($scope.refreshPreview.bind(@), 1000), true
]