# Connect CORS
# Copyright (c) 2010 Antono Vasiljev
# MIT Licensed
"use strict"

url = require("url")

# Setups access for CORS requests.
# http://www.w3.org/TR/cors/
#
# @param {Object} options
# @return {Function}
# @api public
#
# The resource sharing policy described by w3c specification is bound to a particular resource.
# Each resource is bound to the following:
#
# - A list of origins consisting of zero or more origins that are allowed access to the resource.
# - A list of methods consisting of zero or more methods that are supported by the resource.
# - A list of headers consisting of zero or more header field names that are supported by the resource.
# - A supports credentials flag that indicates whether the resource supports user credentials
#   in the request. It is true when the resource does and false otherwise.
#
# the original object can be modified in-place at any time
#
# corsOptions = {
#      origins: ['http://w3.org', ...]
#      methods: ['GET']
#      headers: ['X-Requested-With', 'X-HTTP-Method-Override', 'Content-Type', 'Accept']
#      credentials: false
#      resources: [
#        {
#            pattern: /^\/resource/ || '/resource'
#          , origins: ['http://w3.org', ...],
#          , methods: ['GET', 'POST', 'PUT', ...],
#          , headers: ['X-Header-For', ...],
#          , credentails: true,
#        },
#        ...
#      ]
# }

# TODO: allow headers vs expose headers
defaults =
  origins: []
  methods: ['HEAD', 'GET', 'POST']
  headers: ['X-Requested-With', 'X-HTTP-Method-Override', 'Content-Type', 'Accept']
  credentials: false
  resources: []  # defaults to '/', which defaults to the above

defaultResources = [pattern: '/']
defaultOrigins = ['*']

# MSIE <7 doesn't support CORS
# MSIE == 8 only allows origin '*' and does not allow withCredentials
msiePattern = /MSIE/i
operaPattern = /Opera/i

isMSIE = (req) ->
  agent = req.headers['user-agent'];
  return no unless agent?
  if agent.match(msiePattern) and not agent.match(operaPattern)
  then yes
  else no

selectNotEmpty = (a, b) ->
  return a if a?.length
  return b if b?.length
  return no

# http://stackoverflow.com/questions/3446170/escape-string-for-use-in-javascript-regex/6969486#6969486
escapeRegExp = (str) ->
  str.replace(/[-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, "\\$&")

create = (config) ->
  config = config || {}
  config.origins = config.origins || defaults.origins.slice()
  config.methods = config.methods || defaults.methods.slice()
  config.headers = config.headers || defaults.headers.slice()
  config.credentials = config.credentials || false
  config.resources = config.resources || defaults.resources.slice()

  if config.origins?
    config.origins.forEach (origin, i) ->
      config.origins[i] = origin.toLowerCase()

  # TODO
  # a lot of stuff in this loop could be 'pre-compiled', but then the options wouldn't be 'hot-editable'
  corsHandler = (req, res, next) ->
    origin    = (req.headers.origin || '').toLowerCase() || undefined # purposefully breaks `case-sensitive` rule of 5.1.2
    resource  = url.parse(req.url).pathname
    resources = selectNotEmpty(config.resources, defaultResources)

    resourceHandler = (obj, i) ->
      pattern = obj.pattern
      methods = selectNotEmpty(obj.methods, config.methods)
      headers = selectNotEmpty(obj.headers, config.headers)
      origins = selectNotEmpty(obj.origins, config.origins) || defaultOrigins
      credentials = obj.credentials or config.credentials
      origin  = req.headers.origin

      # 5.1.2, 5.2.2
      # Split the value of the Origin header on the U+0020 SPACE character
      # and if any of the resulting tokens is not a case-sensitive match for
      # any of the values in list of origins do not set any additional headers
      # and terminate this set of steps.
      #
      # NOTE: I purposefully break the `case-sensitive` rule. It's stupid and
      # goes against all previous specifications and common sense
      matchOrigin = (originPattern, i) ->
        if typeof originPattern is 'string'
          if originPattern is '*' then return true
          # it is often useful to run an application on a non-standard port when developing
          # for `http://example.com`, `http://example.com:3000` should match,
          # but `example.com.evil.org` should not
          originPattern = RegExp('^' + escapeRegExp(originPattern) + '(:|$)')
          origins[i]    = originPattern
        if origin.match(originPattern) then yes else no

      # turn the pattern into a regex
      if typeof pattern is 'string'
        pattern = RegExp('^' + escapeRegExp(pattern))
        resources[i].pattern = pattern

      # if there is no match, on to the next array in the array
      if not resource.match(pattern) then return no

      # the origin is wrong, on to the next resource in the array
      if not origins.some(matchOrigin) then return no

      # 5.2.3, 5.2.4, 5.2.5
      # Let method be the value as result of parsing the Access-Control-Request-Method header.
      # If there is no Access-Control-Request-Method header or if parsing failed,
      # do not set any additional headers and terminate this set of steps.
      # The request is outside the scope of this specification.
      #
      # NOTE:
      # 'Access-Control-Request-Method' is only for the OPTIONS pre-flight
      # 'method' is for the regular requests
      if methods.indexOf(String(req.headers['access-control-request-method'] || req.method).toUpperCase()) is -1
        # Options should be allowed even if it isn't allowed
        if req.method.toUpperCase() isnt 'OPTIONS' then return no

      # TODO: implement the rest of 5.2

      # 5.1.3
      # If the resource supports credentials add a single Access-Control-Allow-Origin
      # header, with the value of the Origin header as value, and add a single
      # Access-Control-Allow-Credentials header with the literal string "true" as value.
      #
      # Otherwise, add a single Access-Control-Allow-Origin header, with either the
      # value of the Origin header or the literal string "*" as value.
      #
      # NOTE:
      # Since we can determine the origin programatically, there's no sense in ever
      # using '*', however, MSIE doesn't allow credentials or specific origins
      if isMSIE(req)
        res.setHeader('Access-Control-Allow-Origin', '*')
      else
        # Browsers never need '*', it doesn't provide any extra security
        # plus, this makes it super easy to globally allow `withCredentials`
        res.setHeader('Access-Control-Allow-Origin', origin)

      if credentials then res.setHeader('Access-Control-Allow-Credentials', !!credentials)

      # 5.1.4
      # If the resource wants to expose more than just simple response headers to the
      # API of the CORS API specification add one or more Access-Control-Expose-Headers
      # headers, with as values the filed names of the additional headers to expose.
      #
      # RANT:
      # It seems rather silly that they don't instead specify that if the headers of
      # the API shouldn't be exposed to CORS clients that they simply shouldn't be
      # sent in the first place! Do these people every try to implement these standards
      # before or while they're writing them? Seriously! So much extra logic all over the place...
      #
      # NOTE: These are the 'simple headers' which are automatically exposed
      # Cache-Control
      # Content-Language
      # Content-Type
      # Expires
      # Last-Modified
      # Pragma
      #
      if headers.length
        # headers that the browser should allow client apps to send
        res.setHeader('Access-Control-Allow-Headers', headers.join(', '))
        # headers that the browser should allow client apps to access
        res.setHeader('Access-Control-Expose-Headers', headers.join(', '))

      # NOTE: These are the 'simple methods' which are automatically allowed
      # GET
      # HEAD
      # POST
      if methods.length then res.setHeader('Access-Control-Allow-Methods', methods.join(', '))
      # no need to iterate further
      return true # end resourceHandler()

    # 5.1.1, 5.2.1
    # If the Origin header is not present terminate this set of steps.
    # The request is outside the scope of this specification.
    #
    # NOTE: New tabs in some browsers use `Origin: null`
    # this should match since new tabs are often used when developing
    if typeof origin is 'undefined' then return next()

    # simple pattern-based resource matching
    if not resources.some(resourceHandler) then return next()

    # 5.2
    # pre-flighted requests don't need a body, just headers
    if req.method.match(/^OPTIONS$/i) then return res.end()

    next() # end of corsHandler

  return corsHandler

module.exports.middleware = create