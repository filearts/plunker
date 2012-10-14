#= require ../services/url

#= require ../socialbuttons


module = angular.module("plunker.share", [])

module.directive "plunkerSharePanel", ["$timeout", "url", ($timeout, url) ->
  restrict: "E"
  template: """
    <div class="share-panel">
      <form>
        <label for="share-link">Share link:</label>
        <div class="input-prepend">
          <span class="add-on">
            <i class="icon-link" />
          </span>
          <input id="share-link" class="span4" type="text" value="{{url.www}}{{plunk.getEditUrl()}}"       />
        </div>
        <label for="share-preview">Share preview:</label>
        <div class="input-prepend">
          <span class="add-on">
            <i class="icon-eye-open" />
          </span>
          <input id="share-preview" class="span4" type="text" value="{{url.embed}}/{{plunk.id}}" />
        </div>
        <label for="share-embed">Embed:</label>
        <div>
          <textarea id="share-embed" class="span4">{{createEmbedSnippet(plunk)}}</textarea>
        </div>
        <hr />
        <div class="share-button">
          <a href="https://twitter.com/share" class="twitter-share-button" data-text="Check out this magic I just put together on Plunker" data-size="medium" data-hashtags="plunker">Share on Twitter</a>
          <div class="g-plus" data-action="share" data-height="20" data-annotation="bubble"></div>
        </div>
      </form>
    </div>
  """
  replace: true
  scope:
    plunk: "="
  link: ($scope, el, attrs) ->
    $scope.url = url
    $scope.createEmbedSnippet = (plunk) ->
      """<iframe style="width: 100%; height: 300px" src="#{url.embed}/#{plunk.id}" frameborder="0" allowfullscreen="allowfullscreen"></iframe>"""
      
    $(el).on "click", (e) -> e.stopPropagation()
]