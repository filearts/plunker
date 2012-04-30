url = require("url")

module.exports.middleware = (config = {}) ->
  (req, res, next) ->
    # Just send the headers all the time. That way we won't miss the right request ;-)

    res.header("Access-Control-Allow-Origin", req.headers.origin or "*")
    res.header("Access-Control-Allow-Methods", "OPTIONS,GET,PUT,POST,DELETE")
    res.header("Access-Control-Allow-Headers", "User-Agent, Referer, Proxy-Authorization, Proxy-Connection, Accept-Language, Accept-Encoding, Accept-Charset, Connection, Content-Length, Host, Origin, Pragma, Accept-Charset, Cache-Control, Accept, Content-Type")
    res.header("Access-Control-Allow-Credentials", "true")
    res.header("Access-Control-Max-Age", "60")

    if "OPTIONS" == req.method then res.send(200)
    else next()
