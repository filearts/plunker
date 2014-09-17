var Angular = require("angular");
var DecodeJwt = require("jwt-decode");


module.exports =
Angular.module("plunker.services.visitor", [
  require("angular-cookie").name,
  
  
])

.factory("visitor", ["ipCookie", function (ipCookie) {
  var cookieName = "plunker.jwt";
  
  function Visitor () {
    var cookie = ipCookie(cookieName);
    
    this.jwt = null;
    this.session_id = null;
    this.user = null;
    
    if (cookie) {
      this.setToken(cookie);
    }
  }
  
  Visitor.prototype.isUser = function () {
    return !!this.user;
  };
    
  Visitor.prototype.setToken = function (jwt) {
    try {
      var envelope = DecodeJwt(jwt);
      
      if (!envelope.d) throw new Error("Who are you and what are you doing to my tokens?");
      
      this.jwt = jwt;
      this.session_id = envelope.d.session_id;
      this.user = envelope.d.user;
      
      ipCookie(cookieName, jwt, {
        expires: 14,
        path: "/",
      });
    } catch (e) {
      // TODO: Plug into notifier service
      console.log("[ERR] Invalid auth information");
      
      ipCookie.remove(cookieName);
      
      this.jwt = null;
      this.session_id = null;
      this.user = null;
    }
  };
  
  return new Visitor();
}])

;
