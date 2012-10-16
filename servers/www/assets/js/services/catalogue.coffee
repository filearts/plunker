module = angular.module("plunker.catalogue", [])

module.service "catalogue", [ ->
  catalogue =
    "user-javascript":
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
    "angularjs-resource":
      "category": "AngularJS"
      "versions":
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
    "angularjs-starter":
      "category": "AngularJS"
      "keywords": ["angularjs"]
      "description": """
        Hello world in AngularJS
      """
      "versions":
        "0.0.1":
          "dependencies":
            "angularjs": "1.x"
          "transform": [
            ["html", "attr", "ng-app", "angularjs-starter"]
            ["head", "append", """<script>document.write("<base href=\"" + document.location + "\" />");</script>"""]
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
    "angularjs-starter-coffee":
      "category": "AngularJS"
      "keywords": ["angularjs"]
      "description": """
        Hello world in AngularJS using Coffee-Script
      """
      "versions":
        "0.0.1":
          "dependencies":
            "angularjs": "1.x"
            "coffee-script": "1.x"
          "transform": [
            ["head", "append", """<script>document.write("<base href=\"" + document.location + "\" />");</script>"""]
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
    "bootstrap-starter":
      "category": "Bootstrap"
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
      "tags": ["coffee"]
      "category": "Date / time"
      "versions":
        "1.0.0":
          "transform": [
            ["head", "append", "<script src=\"//cdnjs.cloudflare.com/ajax/libs/datejs/1.0/date.min.js\"></script>"]
          ]
    "moment.js":
      "tags": ["coffee"]
      "category": "Date / time"
      "versions":
        "1.7.2":
          "transform": [
            ["head", "append", "<script src=\"//cdnjs.cloudflare.com/ajax/libs/moment.js/1.7.2/moment.min.js\"></script>"]
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
        versions.push version
      
      unless bestMatch = semver.maxSatisfying(versions, refVersion)
        throw new Error("No package found that satisfies: #{refName}@{refVersion}")
      
      pkg.versions[bestMatch]
      
    
    parseRef: (ref) ->
      parts = ref.split("@")
      
      name = parts.shift()
      version = if parts.length then parts.shift() else "*"
    
      [name, version]

]