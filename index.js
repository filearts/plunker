var Hapi = require("hapi");
var Hoek = require("hoek");
var Config = require("./config." + (process.env.NODE_ENV || "development") + ".js");


// Declare internals

var internals = {};


Config.server.api.uri = (Config.server.api.tls ? "https://" : "http://") + Config.server.api.host + ":" + Config.server.api.port;


var manifest = {
  pack: {
    app: {
      config: Config,
    },
  },
  servers: [
    {
      host: Config.server.api.host,
      port: Config.server.api.port,
      options: {
        labels: ["api", "web"],
        cors: true,
        json: {
          space: 2,
        },
      },
    },
  ],
  plugins: {
    'good': {
      subscribers: {
        console: ['ops', 'request', 'log', 'error']
      },
    },
    './plunker-api-plugin': [{ select: 'api', route: { prefix: "/api" } }],
    './plunker-web-plugin': [{ select: 'web' }],
  }
};


Hapi.Pack.compose(manifest, { relativeTo: __dirname }, function (err, pack) {
  Hoek.assert(!err, "[ERR] Failed to compose pack" + err);

  pack.start(function (err) {
    Hoek.assert(!err, "[ERR] Failed to start servers", err);
    
    pack.log("log", "[OK] Pack started: " + Config.server.api.host + ":" + Config.server.api.port);
  });
});