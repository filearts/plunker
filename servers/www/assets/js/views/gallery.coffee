#= require ../vendor/jquery.timeago
#= require ../vendor/jquery.lazyload

((plunker) ->
  class Card extends Backbone.View
    initialize: ->
      @model.on "change", @render
      @model.on "sync", @flash("Updated")
      @model.on "error", @flash("Error", "warning")
    
    events:
      "click .delete": "onClickDelete"
    
    tagName: "li"
    className: "span3 plunk"

    template: Handlebars.compile """
      <div class="thumbnail">
        <h5 class="description" title="{{description}}">{{description}}</h5>
        <a href="{{html_url}}">
          <img src="http://placehold.it/205x154&text=Loading..." data-original="http://immediatenet.com/t/fs?Size=1024x768&URL={{raw_url}}?_={{dateToTimestamp updated_at created_at}}" class="lazy" />
          <div class="caption">
            <p>
              <abbr class="timeago created_at" title="{{or updated_at created_at}}">{{dateToLocaleString updated_at created_at}}</abbr>
            </p>
          </div>
        </a>
        <ul class="meta">
          <li class="edit">
            <a href="{{edit_url}}" title="Edit this plunk">
              <i class="icon-edit" />
            </a>
          </li>
          <li class="viewers">
            <a href="{{edit_url}}" title="People currently viewing this plunk">
              <i class="icon-eye-open" />
              <span class="live-viewers">0</span>
            </a>
          </li>
          <li class="comments">
            <a href="{{comments_url}}" title="Join the discussion">
              <i class="icon-comments" />
              {{comments}}
            </a>
          </li>

        </ul>
        <ul class="extras">
          {{#if source}}
            <li>
              <a href="{{source.url}}" title="This plunk was imported. Click here to go to its source" target="_blank">
                <i class="icon-link" />
              </a>
            </li>
          {{/if}}
        </ul>
      </div>
      <div class="user">
        {{#if user}}
          <a href="/users/{{user.login}}">
            <img class="gravatar" src="http://www.gravatar.com/avatar/{{user.gravatar_id}}?s=18" />
            {{user.login}}
          </a>
        {{/if}}
      </div>

    """
    
    viewModel: =>
      json = @model.toJSON()
      
      _.extend json,
        html_url: @model.getPreviewUrl()
        edit_url: @model.getEditUrl()
    
    render: =>
      @$el.html @template(@viewModel())
      @$(".timeago").timeago()
      @$("img.lazy").lazyload()
      @$(".tooltip").tooltip()
      
      $viewers = @$(".live-viewers")
      
      viewersRef = new Firebase("http://gamma.firebase.com/filearts/#{@model.id}/viewers")
      
      viewersRef.on "value", (snapshot) -> $viewers.text(snapshot.val().length) unless snapshot.val() is null
      viewersRef.on "child_added", (snapshot) -> $viewers.text parseInt($viewers.text(), 10) + 1
      viewersRef.on "child_removed", (snapshot) -> $viewers.text parseInt($viewers.text(), 10) - 1
      
      @
    
    flash: (message, type = "success") =>
      self = @
      ->
        $tag = $("<span>#{message}</span>").addClass("label label-#{type}")
        self.$(".caption p").prepend($tag)
        
        setTimeout((-> $tag.fadeOut()), 3000)

    
    onClickDelete: ->
      @model.destroy(wait: true) if confirm "Are you sure that you would like to delete this plunk?"




  class plunker.Gallery extends Backbone.View
    initialize: ->
      self = @
      
      @size = 12
      @cards = {}
      
      @collection.on "reset", (coll) ->
        self.removeCard({id: id}, coll) for id, card of self.cards
        coll.chain().first(self.size).each (plunk, index) -> self.addCard(plunk, coll, index)
      @collection.on "add", (plunk, coll, options) -> self.addCard(plunk, coll, options.index)
      @collection.on "remove", (plunk, coll, options) -> self.removeCard(plunk, coll)

    addCard: (plunk, coll, index) =>
      return unless plunk
      
      card = new Card(model: plunk)

      if index
        @$el.children().eq(index - 1).after(card.render().$el)
      else
        @$el.prepend card.render().$el

      @$el.children().slice(@size).remove()

      @cards[plunk.id] = card
      
    removeCard: (plunk, coll) =>
      self = @
      
      card = @cards[plunk.id]
      card.$el.fadeOut "slow", ->
        card.remove()
        self.addCard(self.collection.at(self.size - 1), self.collection, self.size - 1) if self.collection.length >= self.size
      delete @cards[plunk.id]

)(@plunker ||= {})