// Everything starts better with coffee
var coffee = require("coffee-script");
var express = require("express");

var nconf = require("nconf").use("memory")
  .argv({
    "nosubdomains": {
      "boolean": true
    }
  })
  .env()
  .file({file: "config.json"})
  .defaults({
    "PORT": 8080,
    "nosubdomain": false
  });


if (!nconf.get("host")) {
  console.error("The host option is required for Plunker to start");
} else {
  
  var host = nconf.get("host");

  // Configure global paths
  if (nconf.get("nosubdomains") === true) {
    nconf.set("url:www", "http://" + host);
    nconf.set("url:raw", "http://" + host + "/raw");
    nconf.set("url:api", "http://" + host + "/api");
  } else {
    nconf.set("url:www", "http://" + host);
    nconf.set("url:raw", "http://raw." + host);
    nconf.set("url:api", "http://api." + host);
  }    
  
  // Create and start the parent server
  express.createServer()
    .use(express.logger())
    .use(require("express-subdomains").use("raw").use("api").middleware)
    .use(require("./servers/www"))
    .use("/api", require("./servers/api"))
    .use("/raw", require("./servers/raw"))
    .listen(nconf.get("PORT"));
}