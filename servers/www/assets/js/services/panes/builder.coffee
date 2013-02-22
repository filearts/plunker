#= require ../../services/panels
#= require ../../services/scratch

#= require ../../directives/builder

#= require ../../vendor/underscore

module = angular.module("plunker.panels")

module.requires.push("plunker.scratch", "plunker.builder", "plunker.scratch")

module.run [ "panels", "builder", "scratch", (panels, builder, scratch) ->
  panels.push new class
    name: "builder"
    order: 1
    size: 375
    title: "Create a new plunk using the Builder"
    icon: "icon-beaker"
    badge:
      title: "Try out the new Plunk builder"
      class: "badge badge-important"
      value: "new"
    template: """
      <div id="panel-builder">
        <h4>Plunk builder:</h4>
        <details>
          <summary>About the Builder</summary>
          <p>The plunk Builder lets you quickly bootstrap your code with a huge combination of predefined libraries.</p>
          <p>Search for libraries using the magic builder bar below. When you add libraries, their dependencies will
          also be automagically added.</p>
          <p>When you are finished, hit <strong>Create</strong> to load the bootstrapped Plunk
          into the editor.</p>
          <p>Alternatively, hit <strong>Import</strong> to import the selected libraries into your current Plunk.</p>
        </details>
        <p>
          <plunker-builder></plunker-builder>
        </p>
        <p>
          <button title="Create a new Plunk based on the build defined below" class="btn btn-primary" ng-click="launch()">Create</button>
          <button title="Apply the build defined below to the current editor state" class="btn btn-success" ng-click="import()">Import</button>
        <ul>
          <li ng-repeat="(ref, deps) in builder.dependencies">
            <strong>{{ref}}</strong>
            <ul>
              <li ng-repeat="pkg in deps">
                {{pkg.id}}
              </li>
            </ul>
          </li>
        </ul>
        <div class="alert">
          <strong>Hint:</strong> You can pick versions of the libs by putting an '@' after. For example, try 'jquery@'.
        </div>
        <div class="alert">
          <strong>Note:</strong> When you import libraries, Plunker does <strong>not</strong> parse your existing html
          to resolve dependencies based on what already exists. I will see what can be done to improve this.
        </div>
      </div>
    """
          
    link: ($scope, el, attrs) ->
      $scope.builder = builder
      
      $scope.launch = ->
        unless confirm("""
          This operation will overwrite your current work and any work in a connected stream.
          
          Are you sure that you want to reset your session?
        """)
          return
          
        build = angular.extend builder.build(), private: true
        
        scratch.loadJson build,
          skipNext: true
          ignoreLock: true
        builder.reset()
        $scope.resetBar()
      
      $scope.import = ->
        build = builder.build(scratch._getSaveJSON())
        
        for filename, file of build.files
          if buffer = scratch.buffers.findBy("filename", file.filename)
            buffer.content = file.content
          else
            scratch.addFile(file.filename, file.content)
        
        scratch.tags = _.uniq(scratch.tags.concat(build.tags or []))
        
        builder.reset()
        $scope.resetBar()
      
    deactivate: ($scope, el, attrs) ->
      @active = false
      
    activate: ($scope, el, attrs) ->
      @active = true
    
]
