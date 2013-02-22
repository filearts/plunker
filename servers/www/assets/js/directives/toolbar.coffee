#= require ../services/scratch
#= require ../services/downloader

#= require ../directives/share


module = angular.module("plunker.toolbar", ["plunker.share", "plunker.downloader"])

module.directive "plunkerToolbar", ["$location", "scratch", "downloader", ($location, scratch, downloader) ->
  restrict: "E"
  scope: {}
  replace: true
  template: """
    <div id="toolbar" class="btn-toolbar">
      <div class="btn-group" ng-show="scratch.isOwned()">
        <button ng-click="scratch.save()" title="{{saveTitle}}" class="btn btn-primary"><i ng-class="saveIcon"></i><span class="shrink"> Save</span></button>
      </div>
      <div class="btn-group" ng-show="scratch.isSaved()">
        <button ng-click="scratch.fork()" title="Save your changes as a fork of this Plunk" class="btn"><i class="icon-git-fork"></i><span class="shrink"> Fork</span></button>
        <button data-toggle="dropdown" class="btn dropdown-toggle"><span class="caret"></span></button>
        <ul class="dropdown-menu" ng-switch on="scratch.plunk.private">
          <li ng-switch-when="false"><a ng-click="scratch.fork({private: true})">Fork to private plunk</a></li>
          <li ng-switch-when="true"><a ng-click="scratch.fork({private: false})">Fork to public plunk</a></li>
        </ul>
      </div>
      <div ng-show="scratch.isOwned() && scratch.isSaved()" class="btn-group">
        <button ng-click="scratch.promptDestroy()" title="Delete the current plunk" class="btn btn-danger"><i class="icon-trash"></i></button>
      </div>
      <div class="btn-group"><a href="/edit/" title="Start a new plunk from a blank slate" class="btn btn-success"><i class="icon-file"></i><span class="shrink"> New</span></a>
        <button data-toggle="dropdown" class="btn btn-success dropdown-toggle"><span class="caret"></span></button>
        <ul class="dropdown-menu">
          <li><a href="/edit/gist:1986619">jQuery<a href="/edit/gist:1992850" class="coffee" title="In coffee-script"><img src="/img/coffeescript-logo-small_med.png"></a></a></li>
          <li><a href="/edit/gist:2006604">jQuery UI</a></li>
          <li class="divider"></li>
          <li class="dropdown-submenu">
            <a tabindex="-1" href="#">AngularJS</a>
            <ul class="dropdown-menu">
              <li><a href="/edit/b:starter-angularjs">1.0.x (stable)<a href="/edit/b:starter-angularjs-coffee" class="coffee" title="In coffee-script"><img src="/img/coffeescript-logo-small_med.png"></a></a></li>
              <li><a href="/edit/b:angularjs@1.1.x+starter-angularjs">1.1.x (unstable)<a href="/edit/b:angularjs@1.1.x+starter-angularjs-coffee" class="coffee" title="In coffee-script"><img src="/img/coffeescript-logo-small_med.png"></a></a></li>
              <li class="divider"></li>
              <li><a href="/edit/gist:3743008">1.0.2 + Jasmine</a></li>
            </ul>
          </li>
          <li class="divider"></li>
          <li><a href="/edit/gist:2016721">Bootstrap<a href="/edit/gist:2016721" class="coffee" title="In coffee-script"><img src="/img/coffeescript-logo-small_med.png"></a></a></li>
          <li class="divider"></li>
          <li><a href="/edit/gist:2050713">Backbone.js<a href="/edit/gist:2050746" class="coffee" title="In coffee-script"><img src="/img/coffeescript-logo-small_med.png"></a></a></li>
          <li class="divider"></li>
          <li><a href="/edit/gist:3510115">YUI</a></li>
          <li class="divider"></li>
          <li>
            <a href="javascript:void(0)" ng-click="promptImportGist()" title="Import code from a gist or another plunk">Import gist...</a>
          </li>
          <li class="divider"></li>
          <li>
            <div ng-click="builder.launch()" title="Launch the Plunk builder (coming soon...)"><i class="icon-beaker"></i>Launch builder...</div>
          </li>
        </ul>
      </div>
      <div class="btn-group">
          <button ng-click="triggerDownload()" class="btn" title="Save your work as a zip file">
            <i class="icon-download-alt" />
          </button>
      </div>
      <div ng-switch on="scratch.isSaved()" class="btn-group">
        <div ng-switch-when="true">
          <button ng-click="lazyLoadShareButtons()" class="btn btn-warning dropdown-toggle" data-toggle="dropdown" title="Show off your work.">
            <i class="icon-share" />
            <span class="caret"></span>
          </button>
          <plunker-share-panel plunk="scratch.plunk" class="dropdown-menu"></plunker-share-panel>
        </div>
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
  
    $scope.promptImportGist = (source) ->
      if source ||= prompt("Please enter a gist id to import")
        $location.path("gist:#{source}")
    
    $shareBtn = $("#share-buttons")
    
    lazyLoadedShareButtons = false
    
    $scope.triggerDownload = ->
      json = scratch.toJSON()
      
      filename = if scratch.plunk.id then "plunk-#{scratch.plunk.id}.zip" else "plunk.zip"
      
      downloader.download(json, filename)
    
    $scope.lazyLoadShareButtons = ->
      unless lazyLoadedShareButtons
        initSocialButtons()
        lazyLoadedShareButtons = true
]