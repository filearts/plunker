class APIError extends Error
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