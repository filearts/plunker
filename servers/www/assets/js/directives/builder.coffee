#= require ../../select2/select2

#= require ../vendor/underscore
#= require ../vendor/semver
#= require ../vendor/beautify

#= require ../services/catalogue
#= require ../services/scratch

module = angular.module("plunker.builder", ["plunker.scratch", "plunker.catalogue"])

module.service "builder", [ "catalogue", (catalogue) ->
  new class Builder
    constructor: ->
      @reset()
    
    reset: ->
      @catalogue = catalogue
      @packages = [] # Ordered list of all packages
      @names = []
      @dependencies = {} # Mapping of selected packages to their resolved dependencies
      @after = {} # After constraints
    
    getUnusedCatalogueItems: ->
      unused = []
      
      for name, pkg of catalogue.catalogue
        if @names.indexOf(name) < 0
          unused.push catalogue.getBestMatch(name)
          
      unused
    
    addDependencies: (lib, index, parent) ->
      @dependencies[parent] ||= []
      
      if lib.dependencies
        for depName, depVersion of lib.dependencies
          dep = catalogue.getBestMatch("#{depName}@#{depVersion}")
          
          @addLib(dep, index, parent)
          
          index++ if index
          
          @dependencies[parent].push dep
      
      index
    
    removeLib: (lib) ->
      throw new Error("Cannot remove lib not added: #{lib}") unless @dependencies[lib]
      
      for dep in @dependencies[lib]
        idx = @packages.indexOf(dep)
        
        @packages.splice(idx, 1)
      
      lib = catalogue.getBestMatch(lib) if _.isString(lib)

    
    addLib: (lib, index, parent) ->
      lib = catalogue.getBestMatch(lib) if angular.isString(lib)
      
      return if @names.indexOf(lib.name) >= 0
      
      throw new Error("Invalid lib") unless lib
      
      if lib.after
        (@after[after] ||= []).push lib for after in lib.after
      
      if after = @after[lib.name]
        index = @packages.length
        for other in after
          index = Math.min(index, @packages.indexOf(other))
      
      index = @addDependencies(lib, index, parent or lib.name)
      
      if index? then @packages.splice(index, 0, lib)
      else @packages.push(lib)
      
      @names.push(lib.name)
    
    applyTransformation: (doc, selector, method, args...) ->
      switch method
        when "append"
          if selector is "head"
            ih = doc.head
            for tag in args
              ih.innerHTML += tag unless ih.innerHTML.indexOf(tag) >= 0
          else  
            $(selector, doc).append(args...)
        when "attr" then $(selector, doc).attr(args...)
    
    build: (json = {}) ->
      json.description ||= "Custom Plunk"
      json.tags ||= []
      json.files ||= {}
      
      content = """
        <!DOCTYPE html>
        <html>
        
          <head lang="en">
            <meta charset="utf-8">
            <title>Custom Plunker</title>
          </head>
          
          <body>
          </body>
          
        </html>
      """
      
      if index = json.files["index.html"]
        content = index.content
        
      doc = window.document.implementation.createHTMLDocument("")
      doc.documentElement.innerHTML = content

      
      for lib in @packages
        json.tags = json.tags.concat(lib.tags)
        
        for transform in lib.transform
          @applyTransformation(doc, transform...)
        
        angular.extend json.files, lib.files
      
      serializer = new XMLSerializer()
      html = serializer.serializeToString(doc)

      json.tags = _.uniq(json.tags)

      json.files["index.html"] =
        filename: "index.html"
        content: style_html(html, {
          'indent_size': 2
          'indent_char': ' '
          'max_char': 78
          'brace_style': 'expand'
        })
      
      json
    
]

module.directive "plunkerBuilder", ["$timeout", "builder", "scratch", ($timeout, builder, scratch) ->
  restrict: "E"
  replace: true
  scope: {}
  template: """
    <input type="text" style="width: 100%" value="" />
  """
  link: ($scope, $el, attrs) ->
    format = (state) ->
      return state.text unless state.id
      
      state.text
      
    $scope.$parent.resetBar = ->
      $select.select2("val", "")
    
    $select = $el.select2
      width: "100%"
      minimumInputLength: 0
      multiple: true
      formatResult: format
      formatSelection: format
      placeholder: "Click to add packages..."
      allowClear: true
      query: (options) ->
        results = {}
        ret = []
        
        for def in builder.getUnusedCatalogueItems()
          if options.matcher(options.term, def.name) or options.matcher(options.term, def.keywords.join(" "))
            results[def.category] ||=
              text: def.category
              children: []
            
            results[def.category].children.push
              text: def.name
              id: def.id
              pkg: def
              
        for category, result of results
          ret.push(result)
        
        options.callback(results: ret)
    
    $select.on "change", (e) -> $scope.$apply ->
      builder.reset()
      
      for item in e.val
        builder.addLib(item)

]