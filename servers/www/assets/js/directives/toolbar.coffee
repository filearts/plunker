#= require ../vendor/angular

#= require ../services/scratch

#= require ../directives/share


module = angular.module("plunker.toolbar", ["plunker.share"])

module.directive "plunkerToolbar", ["scratch", (scratch) ->
  restrict: "E"
  scope: {}
  template: """
    <div id="toolbar" class="btn-toolbar">
      <div class="btn-group" ng-show="scratch.isOwned()">
        <button ng-click="scratch.save()" title="{{saveTitle}}" class="btn btn-primary"><i ng-class="saveIcon"></i> Save</button>
      </div>
      <div class="btn-group" ng-show="scratch.isSaved()">
        <button ng-click="scratch.fork()" title="Save your changes as a fork of this Plunk" class="btn"><i class="icon-git-fork"></i> Fork</button>
      </div>
      <div ng-show="scratch.isOwned() && scratch.isSaved()" class="btn-group">
        <button ng-click="scratch.promptDestroy()" title="Delete the current plunk" class="btn btn-danger"><i class="icon-trash"></i></button>
      </div>
      <div class="btn-group"><a href="/edit/" title="Start a new plunk from a blank slate" class="btn btn-success"><i class="icon-file"></i> New</a>
        <button data-toggle="dropdown" class="btn btn-success dropdown-toggle"><span class="caret"></span></button>
        <ul class="dropdown-menu">
          <li><a href="/edit/gist:1986619">jQuery<a href="/edit/gist:1992850" class="coffee"><img src="/img/coffeescript-logo-small_med.png"></a></a></li>
          <li><a href="/edit/gist:1986619">jQuery UI</a></li>
          <li class="divider"></li>
          <li><a href="/edit/gist:2246015">AngularJS<a href="/edit/gist:3189582" class="coffee"><img src="/img/coffeescript-logo-small_med.png"></a></a></li>
          <li class="divider"></li>
          <li><a href="/edit/gist:2016721">Bootstrap<a href="/edit/gist:2016721" class="coffee"><img src="/img/coffeescript-logo-small_med.png"></a></a></li>
          <li class="divider"></li>
          <li><a href="/edit/gist:2050713">Backbone.js<a href="/edit/gist:2050746" class="coffee"><img src="/img/coffeescript-logo-small_med.png"></a></a></li>
          <li class="divider"></li>
          <li><a href="/edit/gist:1990582">YUI</a></li>
          <li class="divider"></li>
          <li>
            <div ng-click="builder.launch()" title="Launch the Plunk builder (coming soon...)"><i class="icon-beaker"></i>Launch builder...</div>
          </li>
        </ul>
      </div>
      <div ng-show="scratch.isSaved()" class="btn-group">
        <a href="javascript:void(0)" class="btn btn-warning dropdown-toggle" data-toggle="dropdown">
          <i class="icon-share" /> Share
          <span class="caret"></span>
        </a>
        <plunker-share-panel plunk="scratch.plunk" class="dropdown-menu"></plunker-share-panel>
      </div>
    </div>
  """
  link: ($scope, el, attrs) ->
    $scope.scratch = scratch

    # Watch the ownership of the active plunk and change the save text accordingly
    $scope.$watch "scratch.isSaved()", (isSaved) ->
      if isSaved
        $scope.saveText = "Save"
        $scope.saveTitle = "Save your work as a new Plunk"
        $scope.saveIcon = "icon-save"
      else
        $scope.saveText = "Fork"
        $scope.saveTitle = "Save your work as a fork of the original Plunk"
        $scope.saveIcon = "icon-save"
  

]