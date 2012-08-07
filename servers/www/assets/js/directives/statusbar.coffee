#= require ../vendor/angular

#= require ../services/scratch

module = angular.module("plunker.statusbar", [])

module.directive "plunkerStatusbar", ["scratch", (scratch) ->
  restrict: "E"
  template: """
    <div class="editor-status">
      <div class="navbar navbar-fixed-bottom">
        <div class="navbar-inner">
          <ul class="nav">
            <li class="dropdown"><a href="javascript:void(0)" data-toggle="dropdown" class="dropdown-toggle">{{scratch.active().filename}}<b class="caret"></b></a>
              <ul id="editor-file-list" class="dropdown-menu">
                <li class="file-add"><a href="javascript:void(0)" ng-click="scratch.promptFileAdd()">Add file...</a></li>
                <li class="divider"></li>
                <li ng-repeat="file in scratch.getValidFiles()" ng-class="{active:file==scratch.active()}" class="file">
                  <a href="javascript:void(0)" ng-click="scratch.activate(file)" ng-dblclick="scratch.promptFileRename(file.filename)" class="buffer">{{file.filename}}</a>
                  <ul class="file-ops">
                    <li class="delete">
                      <button ng-click="scratch.promptFileRemove(file.filename)" class="btn btn-mini"><i class="icon-remove"></i></button>
                    </li>
                  </ul>
                </li>
              </ul>
            </li>
            <li class="divider-vertical"></li>
          </ul>
        </div>
      </div>
    </div>
  """
  link: ($scope, el, attrs) ->
    $scope.scratch = scratch  

]