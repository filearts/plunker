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
    
    $scope.refreshPreview = ->
      json = { files: {} }
      
      for filename, file of $scope.scratch.files
        json.files[file.filename] =
          content: file.content
      
      request = $http.post("#{url.api}/previews", json)
      
      request.then (response) ->
        $preview.remove() if $preview
        $preview = $("<iframe>", src: response.data.run_url, class: "plnk-runner", frameborder: 0, width: "100%", height: "100%", scrolling: "auto").appendTo(el).fadeIn()
        
        
    
    $scope.$watch "scratch.files", debounce($scope.refreshPreview.bind(@), 1000), true
]