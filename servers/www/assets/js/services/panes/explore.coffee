#= require ../../directives/card

#= require ../../services/panels
#= require ../../services/plunks

module = angular.module("plunker.panels")

module.requires.push("plunker.card")

module.run [ "$location", "panels", "Plunk", ($location, panels, Plunk) ->
  activated = false
  
  panels.push new class
    name: "explore"
    order: 2
    size: 304
    title: "Find and discover other plunks"
    icon: "icon-th"
    template: """
      <div id="panel-explore" class="cards">
        <div class="page-header">
          <div class="pagination pull-right">
            <ul>
              <li ng-class="{disabled: !plunks.pager.prev}"><a ng-href="javascript:void(0)" ng-click="pageTo(plunks.pager.prev)">«</a></li>
              <li ng-class="{disabled: !plunks.pager.next}"><a ng-href="javascript:void(0)" ng-click="pageTo(plunks.pager.next)">»</a></li>
            </ul>
          </div>
          <button class="btn btn-large btn-success" ng-click="refresh()">
            <i class="icon-refresh" />
            Refresh
          </button>
        </div>
        


        <ul id="gallery" class="thumbnails cards"><card model="plunk" ng-repeat="plunk in plunks"></card></ul>
        <ul class="pager">
          <li ng-show="plunks.pager.prev" class="previous"><a ng-href="" ng-click="pageTo(plunks.pager.prev)">&larr; Newer</a></li>
          <li ng-show="plunks.pager.next" class="next"><a ng-href="javascript:void(0)" ng-click="pageTo(plunks.pager.next)">Older  &rarr;</a></li>
        </ul>
      </div>
    """
          
    link: ($scope, el, attrs) ->
            
      
    deactivate: ($scope, el, attrs) ->
      @active = false
      
    activate: ($scope, el, attrs) ->
      unless activated
        self = @
        
        $scope.refresh = (search = {}) ->
          page = parseInt(search.p, 10) or 1
          size = parseInt(search.pp, 10) or 8
          
          $scope.plunks = Plunk.query
            page: page
            size: size
            
        $scope.$watch (-> $location.search()), $scope.refresh
        
        $scope.pageTo = (url) ->
          matches = url.match(/\?p=(\d+)&pp=(\d+)/i)
          
          search = $location.search()
          search.p = matches[1] or 1
          search.pp = matches[2] or 8
          
          $location.search(search)
          $scope.refresh(search)

      activated = true
      
      @active = true
]
