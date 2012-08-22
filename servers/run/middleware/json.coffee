module.exports.middleware = (config = {}) ->
  (req, res, next) ->
    if "GET" == req.method or "HEAD" == req.method then return next()
    
    req.body ||= {}
    
    buf = '';
    
    req.setEncoding('utf8');
    req.on "data", (chunk) -> buf += chunk
    req.on "end", ->
      return next() unless buf
      try
        req.body = JSON.parse(buf)
        next()
      catch err
        next(err)