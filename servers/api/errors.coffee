module.exports =
  ParseError: class extends Error
    constructor: ->
      @code = 400
      @message = "Problems parsing JSON"
  ValidationError: class extends Error
    constructor: (@errors) ->
      @code = 422
      @message = "Validation failed"
  NotFound: class extends Error
    constructor: ->
      @code = 404
      @message = "Not found"