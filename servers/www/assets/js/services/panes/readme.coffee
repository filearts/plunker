#= require ../../vendor/showdown
#= require ../../vendor/prettify

#= require ../../services/panels
#= require ../../services/scratch

module = angular.module("plunker.panels")

module.requires.push("ngSanitize")

module.filter "markdown", ->
  converter = new Showdown.converter()
  (value) -> converter.makeHtml(value)
  

module.run [ "panels", "scratch", (panels, scratch) ->
  panels.push new class
    name: "readme"
    order: 1
    size: "50%"
    title: "Show the readme for the current plunk"
    icon: "icon-info-sign"
    hidden: true
    template: """
      <div id="panel-readme" ng-switch on="getReadme()!=null">
        <div ng-switch-when="true" ng-bind-html="getReadme() | markdown"></div>
      </div>
    """
          
    link: ($scope, el, attrs) ->
      self = @
      
      $scope.getReadme = ->
        if buffer = scratch.buffers.findBy("filename", "README.md")
          return buffer.content
        return null
          
      $scope.$watch "getReadme()", (readme) ->
        self.hidden = readme == null    
]
