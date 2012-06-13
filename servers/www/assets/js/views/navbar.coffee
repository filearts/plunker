#= require ../vendor/jquery
#= require ../vendor/underscore
#= require ../vendor/backbone
#= require ../vendor/handlebars

((plunker) ->
  
  class NavbarLink extends Backbone.View
    tagName: "li"
    template: Handlebars.compile """
      <a href="{{url}}" title="{{title}}">
        <i class="{{icon}}" />{{title}}
      </a>
    """    
    
    viewModel: =>
      json = @model.toJSON()
      
      _.extend json, {}

    
    render: =>
      @$el.html @template(@viewModel())
      
      @$el.addClass("active") if @model.get("url") is location.pathname
      
      @

      
  
  class plunker.Navbar extends Backbone.View  
    initialize: ->
      @views = {}
      
      @collection.on "reset", @onSectionsReset
      @collection.on "add", @onSectionsAdd
      @collection.on "remove", @onSectionsRemove
      #@collection.on "change", @onSectionsChange

      @onSectionsReset(@collection)

    onSectionsReset: (coll, options = {}) =>
      self = @
      
      for oid, section of @views
        @onSectionsRemove(section, coll, options)
        
      coll.each (section) -> self.onSectionsAdd(section, coll, options)
    
    onSectionsAdd: (section, coll, options = {}) =>
      link = new NavbarLink(model: section)
      
      @$el.append link.render().$el
      @views[section.cid] = link
    
    onSectionsRemove: (section, coll, option = {}) =>
      if link = @views[section.cid]
        link.remove()
        delete @views[section.cid]
      
)(@plunker or @plunker = {})