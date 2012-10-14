#= require ../vendor/noty/jquery.noty
#= require ../vendor/noty/layouts/bottomRight
#= require ../vendor/noty/themes/default


module = angular.module("plunker.notifier", [])

module.factory "notifier", [ () ->
  
  notifier = {}
  methods = ["alert", "success", "error", "warning", "information", "confirm"]
  
  for method in methods then do (method) ->
    notifier[method] = (title, text, options = {}) ->
      switch arguments.length
        when 3
          options.title = title
          options.text = text
        when 2
          if angular.isObject(text)
            options = text
            options.text = title
        when 1
          if angular.isObject(title)
            options = title
          else options.text = title
          
      options.layout ||= "bottomRight"
      options.type ||= method
      options.timeout ||= "3000"
      options.text = (if options.title then "#{options.title} - " else "") + options.text
      
      noty(options)
  
  notifier
]