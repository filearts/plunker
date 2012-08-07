#= require ../../vendor/jquery
#= require ../../vendor/angular

#= require ../../services/panels

module = angular.module("plunker.panels")

module.run [ "panels", (panels) ->
  panels.push new class
    name: "comments"
    order: 2
    size: 200
    title: "Show/hide the live discussion pane"
    icon: "icon-comments-alt"
    template: """
      <div class="plnk-compiler">
        <h1>Live discussion</h1>
        <p>Coming soon</p>
      </div>
    """
          
    link: ($scope, el, attrs) ->
      
    deactivate: ($scope, el, attrs) ->
      
      @enabled = false
      
    activate: ($scope, el, attrs) ->
      
      @enabled = true
]
