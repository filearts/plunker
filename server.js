// Everything starts better with coffee
var coffee = require("coffee-script");
var express = require("express");


var nconf = require("nconf").use("memory")
  .argv()
  .env()
  .file({file: "config.json"})
  .defaults({
    "PORT": process.env.VCAP_APP_PORT || 80
  });

if (!nconf.get("host")) {
  console.error("The host option is required for Plunker to start");
} else {

  var host = nconf.get("host");

  // Configure global paths
  if (nconf.get("nosubdomains")) {
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
    .use("/api", require("./servers/api"))
    .use("/raw", require("./servers/raw"))
    .use(require("./servers/www"))
    .listen(nconf.get("PORT"));
  
  console.log("Started plunker at", nconf.get("host"), "on port", nconf.get("PORT"), "using subdomains:", !nconf.get("nosubdomains"));
}
