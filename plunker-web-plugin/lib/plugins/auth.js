var Boom = require("boom");
var Genid = require("genid");
var Hoek = require("hoek");
var Jwt = require("jsonwebtoken");


module.exports = function (server, options) {

  Hoek.assert(options, 'Missing token cookie auth strategy options');
  Hoek.assert(!options.validateFunc || typeof options.validateFunc === 'function', 'Invalid validateFunc method in configuration');
  Hoek.assert(options.key, 'Missing required key in configuration');

  var settings = Hoek.clone(options);            // Options can be reused
  settings.cookie = settings.cookie || 'plunker.jwt';
  
  var createJwt = function () {
    var payload = {
      v: 0,
      d: {
        session_id: Genid(),
        user: null,
      },
    };
    
    return Jwt.sign(payload, settings.key);
  };

  var cookieOptions = {
    isSecure: !!settings.isSecure,
    path: '/',
    isHttpOnly: !!settings.isHttpOnly,
    autoValue: function (request, next) {
      var jwt = request.state[settings.cookie];
      
      if (!jwt) {
        jwt = createJwt();
      }
      
      next(null, jwt);
    },
  };

  if (settings.ttl) {
    cookieOptions.ttl = settings.ttl;
  }

  if (settings.domain) {
    cookieOptions.domain = settings.domain;
  }

  server.state(settings.cookie, cookieOptions);

  var scheme = {
    authenticate: function (request, reply) {
      // Check cookie
      var jwt = request.state[settings.cookie];

      if (!jwt) {
        jwt = request.state[settings.cookie] = createJwt();
      }
      
      Jwt.verify(jwt, settings.key, function (err, credentials) {
        if (err) {
          delete request.state[settings.cookie];
          
          // Try again... dangerously
          return scheme.authenticate(request, reply);
        }
        
        return reply(null, {
          credentials: {
            user: credentials.d.user,
            session_id: credentials.d.session_id,
            jwt: jwt,
          }
        });
      });
    }
  };

  return scheme;
};