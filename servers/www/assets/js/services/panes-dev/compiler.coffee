#= require ../../vendor/jquery
#= require ../../vendor/angular

#= require ../../services/panels
#= require ../../services/scratch

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

module.run ["$http", "panels", "scratch", "url", ($http, panels, scratch) ->
  panels.push new class
    name: "compiler"
    order: 1
    title: "Show/hide the live compilation and linting pane"
    icon: "icon-magic"
    template: """
      <div class="plnk-compiler">
        <h1>Live compilation and linting</h1>
        <p>Coming soon...</p>
      </div>
    """
          
    link: ($scope, el, attrs) ->
      
    deactivate: ($scope, el, attrs) ->
      
      @enabled = false
      
    activate: ($scope, el, attrs) ->
      
      @enabled = true
]
