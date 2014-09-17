var Path = require("path");
var Promise = require("bluebird");
var Webpack = require("webpack");

var internals = {};

exports.register = function (plugin, options, next) {
  Promise.promisifyAll(plugin);
  
  plugin.bind({
    config: plugin.app.config,
  });
  
  plugin.auth.scheme("cookie-jwt", require("./plugins/auth"));
  
  plugin.auth.strategy("cookie", "cookie-jwt", {
    key: plugin.app.config.auth.secret
  });
  
  plugin.route({
    method: "GET",
    path: "/{any*}",
    config: {
      auth: "cookie",
      handler: {
        file: {
          path: Path.join(__dirname, "../static", "index.html"),
        },
      },
    },
  });

  plugin.route({
    method: "GET",
    path: "/static/{any*}",
    handler: {
      directory: {
        path: Path.join(__dirname, "../static")
      },
    },
  });
  
  next();
  
  internals.buildAssets(plugin, plugin.app.config.shared);
};

exports.register.attributes = {
  pkg: require('../package.json')
};




internals.buildAssets = function (plugin, options) {
  var configure = require("../webpack.config");
  var config = configure(options);
  var compiler = Webpack(config);
  
  var resolved = false;
  
  return new Promise(function (resolve, reject) {
    plugin.log("log", "[OK] Starting asset build...");
    compiler.watch(200, function (err, stats) {
      if (err) {
        plugin.log("error", "[ERR] Webpack build failed");
      }
      
      if (!resolved && err) {
        reject(err);
      } else if (!resolved) {
        resolve(stats);
      }
      
      resolved = true;
      
      console.log("[OK] Webpack build completed:", stats.toString({colors: true}));
    });
  });
};