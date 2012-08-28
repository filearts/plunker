#= require ../services/scratch

module = angular.module("plunker.statusbar", [])

module.directive "plunkerStatusbar", ["scratch", (scratch) ->
  restrict: "E"
  template: """
    <div class="editor-status">
      <div class="navbar navbar-fixed-bottom navbar-inverse">
        <div class="navbar-inner">
          <ul class="nav">
            <li class="dropdown"><a href="javascript:void(0)" data-toggle="dropdown" class="dropdown-toggle">{{scratch.buffers.active().filename}}<b class="caret"></b></a>
              <ul id="editor-file-list" class="dropdown-menu">
                <li class="file-add"><a href="javascript:void(0)" ng-click="scratch.promptFileAdd()">Add file...</a></li>
                <li class="divider"></li>
                <li ng-repeat="buffer in scratch.buffers.queue | orderBy:'filename'" ng-class="{active:buffer==scratch.buffers.active()}" class="file">
                  <a href="javascript:void(0)" ng-click="scratch.buffers.activate(buffer)" ng-dblclick="scratch.promptFileRename(buffer.filename)" class="buffer">{{buffer.filename}}</a>
                  <ul class="file-ops">
                    <li class="delete">
                      <button ng-click="scratch.promptFileRemove(buffer.filename)" class="btn btn-mini"><i class="icon-remove"></i></button>
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