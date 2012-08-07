#= require ../../vendor/jquery
#= require ../../vendor/angular

#= require ../../services/panels

module = angular.module("plunker.panels")

module.run [ "panels", (panels) ->
  panels.push new class
    name: "comments"
    order: 99
    size: 280
    title: "Show/hide the settings pane"
    icon: "icon-cogs"
    template: """
      <div class="plnk-settings row-fluid">
        <h1>Settings</h1>
        <p>Coming soon...</p>
      </div>
    """
          
    link: ($scope, el, attrs) ->
      
    deactivate: ($scope, el, attrs) ->
      
      @enabled = false
      
    activate: ($scope, el, attrs) ->
      
      @enabled = true
]
