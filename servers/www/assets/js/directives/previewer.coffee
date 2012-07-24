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

module.directive "previewer", ["$http", "url", ($http, url) ->
  restrict: "E"
  replace: true
  template: """
    <div class="plnk-previewer"></div>
  """
  link: ($scope, el, attrs) ->
    $preview = null
    
    $scope.refreshPreview = debounce ->
      json = { files: {} }
      
      for filename, file of $scope.scratch.files
        json.files[file.filename] =
          content: file.content
      
      request = $http.post("#{url.api}/previews", json)
      
      request.then (response) ->
        $preview.remove() if $preview
        $preview = $("<iframe>", src: response.data.run_url, class: "plnk-runner").appendTo(el).fadeIn()

    , 1000
        
        
    
    $scope.$watch "active.content", ->
      $scope.refreshPreview()
]