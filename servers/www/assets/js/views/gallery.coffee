#= require ../../vendor/jquery.timeago
#= require ../../vendor/jquery.lazyload

((plunker) ->
  class Card extends Backbone.View
    initialize: ->
      console.log "Model", @model
      
      @model.on "change", @render
      @model.on "sync", @flash("Updated")
      @model.on "error", @flash("Error", "warning")
    
    events:
      "click .delete": "onClickDelete"
    
    tagName: "li"
    className: "span3 plunk"

    template: """
      <div class="thumbnail">
        <h5 class="description" title="{{description}}">{{description}}</h5>
        <a href="{{html_url}}">
          <img src="http://placehold.it/205x154&text=Loading..." data-original="http://immediatenet.com/t/l3?Size=1024x768&URL={{raw_url}}?_={{dateToTimestamp updated_at created_at}}" class="lazy" />
        </a>
        <div class="caption">
          <p>
            {{#if user}}
              by&nbsp;<span class="user">{{user.login}}</span>
            {{else}}
              by&nbsp;Anonymous
            {{/if}}
            <abbr class="timeago created_at" title="{{or updated_at created_at}}">{{dateToLocaleString updated_at created_at}}</abbr>
            {{#if source}}
              based on&nbsp;<a href="{{source.url}}" target="_blank">{{source.name}}</a>
            {{/if}}
          </p>
        </div>
          <div class="operations">
            <div class="btn-toolbar">
              {{#if token}}
                <a class="btn btn-mini btn-primary edit" title="Edit in Plunker" href="/edit/{{id}}">
                  <i class="icon-pencil icon-white"></i>
                </a>
                <button class="btn btn-mini btn-danger delete" title="Delete">
                  <i class="icon-trash icon-white"></i>
                </button>
              {{else}}
                <a class="btn btn-mini btn-primary edit" title="Fork and edit in Plunker" href="/edit/{{id}}">
                  <i class="icon-pencil icon-white"></i>
                </a>              
              {{/if}}
            </div>
          </div>
      </div>
    """
    
    viewModel: =>
      json = @model.toJSON()
      
      _.extend json,
        html_url: plunker.router.url("www") + "/#{json.id}/"
    
    render: =>
      compiled = Handlebars.compile(@template)
      @$el.html $(compiled(@viewModel()))
      @$(".timeago").timeago()
      @$("img.lazy").lazyload()
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
      @collection.on "destroy", (plunk, coll, options) -> self.removeCard(plunk, coll)

    addCard: (plunk, coll, index) =>
      console.log "Addcard", arguments...
      return unless plunk
      
      card = new Card(model: plunk)

      if index
        @$el.children().eq(index - 1).after(card.render().$el)
      else
        @$el.prepend card.render().$el

      @$el.children().slice(@size).remove()

      @cards[plunk.id] = card
      
    removeCard: (plunk, coll) =>
      console.log "Removecard", arguments...
      self = @
      
      card = @cards[plunk.id]
      card.$el.fadeOut "slow", ->
        card.remove()
        self.addCard(self.collection.at(self.size - 1), self.collection, self.size - 1) if self.collection.length >= self.size
      delete @cards[plunk.id]

)(@plunker ||= {})