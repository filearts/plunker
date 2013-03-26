createErrorClass = (name, message = "") ->
  class extends Error
    constructor: (@message = message, options = {}) ->
      Error.call(@)
      Error.captureStackTrace(@, arguments.callee)
      
      @name = options.name or name
      
      @[prop] = val for own prop, val of options
        

class APIError extends Error
  constructor: ->
    Error.call(@)
    Error.captureStackTrace(@, arguments.callee)
  toJSON: -> {@code, @message}

module.exports =
  ParseError: class extends APIError
    constructor: ->
      @code = 400
      @message = "Problems parsing JSON"
  ValidationError: class extends APIError
    constructor: (@errors) ->
      @code = 422
      @message = "Validation failed"
    toJSON: -> {@errors, @code, @message}
  NotFound: class extends APIError
    constructor: ->
      @code = 404
      @message = "Not found"
  PermissionDenied: class extends APIError
    constructor: ->
      @code = 404
      @message = "Permission denied"
  InternalServerError: class extends APIError
    constructor: ->
      @code = 500
      @message = "Internal server error"
  DatabaseError: createErrorClass("DatabaseError", "Database error")