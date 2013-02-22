module = angular.module("plunker.catalogue", [])

module.service "catalogue", [ ->
  catalogue =
    "starter":
      "category": "Starter Templates"
      "tags": []
      "description": """
        Basic starter template with a javascript and css file
      """
      "versions":
        "0.0.1":
          "dependencies":
            "user-css": "*"
            "user-js": "*"

    "starter-coffee":
      "category": "Starter Templates"
      "tags": []
      "description": """
        Basic starter template with a coffee-script and css file
      """
      "versions":
        "0.0.1":
          "dependencies":
            "user-css": "*"
            "user-coffee": "*"
            
    "user-js":
      "versions":
        "0.1.1":
          "after": ["jquery","jquery-ui","bootstrap-js","angularjs"]
          "transform": [
            ["head", "append", "<script src=\"script.js\"></script>"]
          ]
          "files":
            "script.js": """
              /* Code goes here */
            """
    "user-css":
      "versions":
        "0.1.1":
          "after": ["jquery-ui","bootstrap-css-combined","angularjs"]
          "transform": [
            ["head", "append", "<link rel=\"stylesheet\" href=\"style.css\">"]
          ]
          "files":
            "style.css": """
              /* CSS goes here */
            """
    "user-coffee":
      "versions":
        "0.1.1":
          "after": ["jquery","jquery-ui","bootstrap-js","angularjs"]
          "dependencies":
            "coffee-script": "*"
          "transform": [
            ["head", "append", "<script type=\"text/coffeescript\" src=\"script.coffee\"></script>"]
          ]
          "files":
            "script.coffee": """
              # Coffee-script goes here
            """
    "jquery":
      "tags": ["jquery"]
      "category": "jQuery"
      "versions":
        "1.8.3":
          "transform": [
            ["head", "append", "<script src=\"//ajax.googleapis.com/ajax/libs/jquery/1.8.3/jquery.min.js\"></script>"]
          ]
        "1.8.2":
          "transform": [
            ["head", "append", "<script src=\"//ajax.googleapis.com/ajax/libs/jquery/1.8.2/jquery.min.js\"></script>"]
          ]
        "1.7.2":
          "transform": [
            ["head", "append", "<script src=\"//ajax.googleapis.com/ajax/libs/jquery/1.7.2/jquery.min.js\"></script>"]
          ]
    "jquery-ui":
      "tags": ["jquery-ui"]
      "category": "jQuery"
      "versions":
        "1.8.23":
          "dependencies":
            "jquery": "1.8.x"
          "transform": [
            ["head", "append", "<link href=\"//ajax.googleapis.com/ajax/libs/jqueryui/1.8.23/themes/base/jquery-ui.css\" rel=\"stylesheet\">"]
            ["head", "append", "<script src=\"//ajax.googleapis.com/ajax/libs/jqueryui/1.8.23/jquery-ui.min.js\"></script>"]
          ]
    "angularjs":
      "tags": ["angularjs"]
      "category": "AngularJS"
      "versions":
        "1.0.3":
          "after": "jquery"
          "transform": [
            ["head", "append", "<script src=\"//ajax.googleapis.com/ajax/libs/angularjs/1.0.3/angular.min.js\"></script>"]
          ]
        "1.0.2":
          "after": "jquery"
          "transform": [
            ["head", "append", "<script src=\"//ajax.googleapis.com/ajax/libs/angularjs/1.0.2/angular.min.js\"></script>"]
          ]
        "1.0.1":
          "after": "jquery"
          "transform": [
            ["head", "append", "<script src=\"//ajax.googleapis.com/ajax/libs/angularjs/1.0.1/angular.min.js\"></script>"]
          ]
        "1.1.0":
          "unstable": true
          "after": "jquery"
          "transform": [
            ["head", "append", "<script src=\"//code.angularjs.org/1.1.0/angular.js\"></script>"]
          ]
        "1.1.1":
          "unstable": true
          "after": "jquery"
          "transform": [
            ["head", "append", "<script src=\"//code.angularjs.org/1.1.1/angular.js\"></script>"]
          ]
    "angularjs-resource":
      "category": "AngularJS"
      "versions":
        "1.0.3":
          "dependencies":
            "angularjs": "1.0.3"
          "transform": [
            ["head", "append", "<script src=\"//ajax.googleapis.com/ajax/libs/angularjs/1.0.3/angular-resource.min.js\"></script>"]
          ]
        "1.0.2":
          "dependencies":
            "angularjs": "1.0.2"
          "transform": [
            ["head", "append", "<script src=\"//ajax.googleapis.com/ajax/libs/angularjs/1.0.2/angular-resource.min.js\"></script>"]
          ]
        "1.0.1":
          "dependencies":
            "angularjs": "1.0.1"
          "transform": [
            ["head", "append", "<script src=\"//ajax.googleapis.com/ajax/libs/angularjs/1.0.1/angular-resource.min.js\"></script>"]
          ]
    "angularjs-cookies":
      "category": "AngularJS"
      "versions":
        "1.0.3":
          "dependencies":
            "angularjs": "1.0.3"
          "transform": [
            ["head", "append", "<script src=\"//ajax.googleapis.com/ajax/libs/angularjs/1.0.3/angular-cookies.min.js\"></script>"]
          ]
        "1.0.2":
          "dependencies":
            "angularjs": "1.0.2"
          "transform": [
            ["head", "append", "<script src=\"//ajax.googleapis.com/ajax/libs/angularjs/1.0.2/angular-cookies.min.js\"></script>"]
          ]
        "1.0.1":
          "dependencies":
            "angularjs": "1.0.1"
          "transform": [
            ["head", "append", "<script src=\"//ajax.googleapis.com/ajax/libs/angularjs/1.0.1/angular-cookies.min.js\"></script>"]
          ]
    "angularjs-sanitize":
      "category": "AngularJS"
      "versions":
        "1.0.3":
          "dependencies":
            "angularjs": "1.0.3"
          "transform": [
            ["head", "append", "<script src=\"//ajax.googleapis.com/ajax/libs/angularjs/1.0.3/angular-sanitize.min.js\"></script>"]
          ]
        "1.0.2":
          "dependencies":
            "angularjs": "1.0.2"
          "transform": [
            ["head", "append", "<script src=\"//ajax.googleapis.com/ajax/libs/angularjs/1.0.2/angular-sanitize.min.js\"></script>"]
          ]
        "1.0.1":
          "dependencies":
            "angularjs": "1.0.1"
          "transform": [
            ["head", "append", "<script src=\"//ajax.googleapis.com/ajax/libs/angularjs/1.0.1/angular-sanitize.min.js\"></script>"]
          ]
    "starter-angularjs":
      "category": "Starter Templates"
      "keywords": ["angularjs"]
      "description": """
        Hello world in AngularJS
      """
      "versions":
        "0.0.1":
          "dependencies":
            "angularjs": "1.0.x"
            "user-css": "*"
          "transform": [
            ["html", "attr", "ng-app", "angularjs-starter"]
            ["head", "append", """<script>document.write('<base href="' + document.location + '" />');</script>"""]
            ["head", "append", "<script src=\"app.js\"></script>"]
            ["body", "attr", "ng-controller", "MainCtrl"]
            ["body", "append", "<h1>Hello {{name}}</h1>"]
          ]
          "files":
            "app.js": """
              var app = angular.module('angularjs-starter', []);
              
              app.controller('MainCtrl', function($scope) {
                $scope.name = 'World';
              });
            """
    "starter-angularjs-coffee":
      "category": "Starter Templates"
      "keywords": ["angularjs"]
      "description": """
        Hello world in AngularJS using Coffee-Script
      """
      "versions":
        "0.0.1":
          "dependencies":
            "angularjs": "1.0.x"
            "coffee-script": "1.x"
            "user-css": "*"
          "transform": [
            ["head", "append", """<script>document.write('<base href="' + document.location + '" />');</script>"""]
            ["head", "append", """<script type="text/coffeescript" src="app.coffee"></script>"""]
            ["body", "attr", "ng-controller", "MainCtrl"]
            ["body", "append", "<h1>Hello {{name}}</h1>"]
          ]
          "files":
            "app.coffee": """
              app = angular.module('angularjs-starter', [])
              
              app.controller 'MainCtrl', ($scope) ->
                $scope.name = 'World'
              
              angular.bootstrap(document, ['angularjs-starter'])
            """
    "angular-ui":
      "category": "AngularJS"
      "tags": ["angular-ui"]
      "versions":
        "0.0.1":
          "dependencies":
            "jquery-ui": ">=1.8.0"
            "angularjs": "1.0.x"
          "transform": [
            ["head", "append", "<script src=\"//raw.github.com/angular-ui/angular-ui/master/build/angular-ui.js\"></script>"]
          ]
    "bootstrap":
      "category": "Bootstrap"
      "keywords": ["bootstrap"]
      "description": """
        Add the full Twitter Bootstrap framework
      """
      "versions":
        "2.1.1":
          "dependencies":
            "bootstrap-css-combined": "2.1.1"
            "bootstrap-js": "2.1.1"
        "2.2.0":
          "dependencies":
            "bootstrap-css-combined": "2.2.0"
            "bootstrap-js": "2.2.0"
    "bootstrap-css-combined":
      "category": "Bootstrap"
      "tags": ["bootstrap"]
      "keywords": ["bootstrap"]
      "description": """
        Add dependencies for Twitter's Bootstrap framework.
        
        Note that this does *not* include the javascript component. Please also include bootstrap-js to get access to that.
      """
      "versions":
        "2.1.1":
          "transform": [
            ["head", "append", "<link href=\"//netdna.bootstrapcdn.com/twitter-bootstrap/2.1.1/css/bootstrap-combined.min.css\" rel=\"stylesheet\">"]
          ]
        "2.2.0":
          "transform": [
            ["head", "append", "<link href=\"//netdna.bootstrapcdn.com/twitter-bootstrap/2.2.0/css/bootstrap-combined.min.css\" rel=\"stylesheet\">"]
          ]
    "bootstrap-js":
      "category": "Bootstrap"
      "keywords": ["bootstrap"]
      "description": """
        Add the javascript components of Twitter's Bootstrap
      """
      "versions":
        "2.1.1":
          "dependencies":
            "jquery": ">= 1.7.0"
          "transform": [
            ["head", "append", "<script src=\"//netdna.bootstrapcdn.com/twitter-bootstrap/2.1.1/js/bootstrap.min.js\"></script>"]
          ]
        "2.2.0":
          "dependencies":
            "jquery": ">= 1.7.0"
          "transform": [
            ["head", "append", "<script src=\"//netdna.bootstrapcdn.com/twitter-bootstrap/2.2.0/js/bootstrap.min.js\"></script>"]
          ]


    "starter-bootstrap":
      "category": "Starter Templates"
      "tags": ["bootstrap"]
      "description": """
        Basic starter template for Twitter's Bootstrap
      """
      "versions":
        "0.0.1":
          "dependencies":
            "bootstrap-css-combined": "*"
            "bootstrap-js": "*"
          "transform": [
            ["body", "append", """<h1>Todo</h1>"""]
          ]
    "coffee-script":
      "tags": ["coffee"]
      "versions":
        "1.3.3":
          "transform": [
            ["head", "append", "<script src=\"//cdnjs.cloudflare.com/ajax/libs/coffee-script/1.3.3/coffee-script.min.js\"></script>"]
          ]
    "date.js":
      "category": "Date / time"
      "versions":
        "1.0.0":
          "transform": [
            ["head", "append", "<script src=\"//cdnjs.cloudflare.com/ajax/libs/datejs/1.0/date.min.js\"></script>"]
          ]
    "moment.js":
      "category": "Date / time"
      "versions":
        "1.7.2":
          "transform": [
            ["head", "append", "<script src=\"//cdnjs.cloudflare.com/ajax/libs/moment.js/1.7.2/moment.min.js\"></script>"]
          ]
    "underscore":
      "category": "Utility"
      "versions":
        "1.4.2":
          "transform": [
            ["head", "append", "<script src=\"//cdnjs.cloudflare.com/ajax/libs/underscore.js/1.4.2/underscore-min.js\"></script>"]
          ]
    "backbone":
      "category": "Backbone"
      "tags": "Backbone"
      "versions":
        "1.4.2":
          "dependencies":
            "jquery": "~1.7.0"
            "underscore": "~1.4.0"
          "transform": [
            ["head", "append", "<script src=\"//cdnjs.cloudflare.com/ajax/libs/backbone.js/0.9.2/backbone-min.js\"></script>"]
          ]
    "backbone-localStorage":
      "category": "Backbone"
      "tags": "Backbone"
      "versions":
        "1.0.0":
          "dependencies":
            "backbone": "~1.4.0"
          "transform": [
            ["head", "append", "<script src=\"//cdnjs.cloudflare.com/ajax/libs/backbone-localstorage.js/1.0/backbone.localStorage-min.js\"></script>"]
          ]
    "knockout":
      "category": "Knockout.js"
      "tags": "knockout"
      "versions":
        "2.1.0":
          "transform": [
            ["head", "append", "<script src=\"//cdnjs.cloudflare.com/ajax/libs/knockout/2.1.0/knockout-min.js\"></script>"]
          ]
    "knockout.mapping":
      "category": "Knockout.js"
      "versions":
        "2.3.2":
          "dependencies":
            "knockout": "2.1.x"
          "transform": [
            ["head", "append", "<script src=\"//cdnjs.cloudflare.com/ajax/libs/knockout.mapping/2.3.2/knockout.mapping.js\"></script>"]
          ]
    "handlebars":
      "category": "Templating"
      "tags": ["handlebars"]
      "versions":
        "1.0.0-RC1":
          "transform": [
            ["head", "append", "<script src=\"//cdnjs.cloudflare.com/ajax/libs/handlebars.js/1.0.rc.1/handlebars.min.js\"></script>"]
          ]
    "ember":
      "category": "Ember.js"
      "tags": ["ember"]
      "versions":
        "1.0.0-pre2":
          "dependencies":
            "jquery": ">=1.7.2"
            "handlebars": "~1.0.0"
          "transform": [
            ["head", "append", "<script src=\"//cdnjs.cloudflare.com/ajax/libs/ember.js/1.0.0-pre.2/ember-1.0.0-pre.2.min.js\"></script>"]
          ]
        "0.9.8":
          "dependencies":
            "jquery": ">=1.7.2"
            "handlebars": "~1.0.0"
          "transform": [
            ["head", "append", "<script src=\"//cdnjs.cloudflare.com/ajax/libs/ember.js/0.9.8/ember-0.9.8.js\"></script>"]
          ]
    "select2":
      "category": "User Interface"
      "tags": ["select2"]
      "versions":
        "3.2.0":
          "dependencies":
            "jquery": ">=1.7.2"
          "transform": [
            ["head", "append", "<link rel=\"stylesheet\" href=\"//ivaynberg.github.com/select2/select2-3.2/select2.css\" />"]
            ["head", "append", "<script src=\"//ivaynberg.github.com/select2/select2-3.2/select2.js\"></script>"]
          ]
    "d3":
      "category": "D3.js"
      "tags": ["d3"]
      "versions":
        "2.7.4":
          "transform": [
            ["head", "append", "<script src=\"//cdnjs.cloudflare.com/ajax/libs/d3/2.7.4/d3.min.js\"></script>"]
          ]
    "d3-time":
      "category": "D3.js"
      "tags": ["d3"]
      "versions":
        "2.7.4":
          "dependencies":
            "d3": "2.7.4"
          "transform": [
            ["head", "append", "<script src=\"//cdnjs.cloudflare.com/ajax/libs/d3/2.7.4/d3.time.min.js\"></script>"]
          ]
    "d3-layout":
      "category": "D3.js"
      "tags": ["d3"]
      "versions":
        "2.7.4":
          "dependencies":
            "d3": "2.7.4"
          "transform": [
            ["head", "append", "<script src=\"//cdnjs.cloudflare.com/ajax/libs/d3/2.7.4/d3.layout.min.js\"></script>"]
          ]
    "d3-geom":
      "category": "D3.js"
      "tags": ["d3"]
      "versions":
        "2.7.4":
          "dependencies":
            "d3": "2.7.4"
          "transform": [
            ["head", "append", "<script src=\"//cdnjs.cloudflare.com/ajax/libs/d3/2.7.4/d3.geom.min.js\"></script>"]
          ]
    "d3-geo":
      "category": "D3.js"
      "tags": ["d3"]
      "versions":
        "2.7.4":
          "dependencies":
            "d3": "2.7.4"
          "transform": [
            ["head", "append", "<script src=\"//cdnjs.cloudflare.com/ajax/libs/d3/2.7.4/d3.geo.min.js\"></script>"]
          ]                              
    "d3-csv":
      "category": "D3.js"
      "tags": ["d3"]
      "versions":
        "2.7.4":
          "dependencies":
            "d3": "2.7.4"
          "transform": [
            ["head", "append", "<script src=\"//cdnjs.cloudflare.com/ajax/libs/d3/2.7.4/d3.csv.min.js\"></script>"]
          ]
    "d3-chart":
      "category": "D3.js"
      "tags": ["d3"]
      "versions":
        "2.7.4":
          "dependencies":
            "d3": "2.7.4"
          "transform": [
            ["head", "append", "<script src=\"//cdnjs.cloudflare.com/ajax/libs/d3/2.7.4/d3.chart.min.js\"></script>"]
          ]


  new class Catalogue
    constructor: ->
      @catalogue = catalogue
      
      # Clean up the libs object
      for name, pkg of @catalogue
        pkg.description ||= ""
        pkg.category ||= "Misc"
        pkg.name = name
        pkg.keywords ||= []
        pkg.tags ||= []
        
        for version, def of pkg.versions
          def.name = name
          def.version = version
          def.keywords = pkg.keywords
          def.description = pkg.description
          def.category = pkg.category
          def.tags = pkg.tags
          def.id = "#{name}@#{version}"
          def.files ||= {}
          def.transform ||= []
          def.after ||= []
          def.after = [def.after] if angular.isString(def.after)
          
          for filename, file of def.files
            if angular.isString(file) then def.files[filename] =
              filename: filename
              content: file
    
    getBestMatch: (ref) ->
      [refName, refVersion] = @parseRef(ref)
      
      unless pkg = @catalogue[refName]
        throw new Error("No such package: #{refName}")
      
      versions = []
      for version, def of pkg.versions
        versions.push version unless def.unstable and refVersion == "*"
      
      unless bestMatch = semver.maxSatisfying(versions, refVersion)
        throw new Error("No package found that satisfies: #{refName}@{refVersion}")
      
      pkg.versions[bestMatch]
      
    
    parseRef: (ref) ->
      parts = ref.split("@")
      
      name = parts.shift()
      version = if parts.length then parts.shift() else "*"
    
      [name, version]

]