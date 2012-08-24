// Everything starts better with coffee
var coffee = require("coffee-script");
var express = require("express");


var nconf = require("nconf").use("memory")
  .argv()
  .env()
  .file({file: "config.json"})
  .defaults({
    "PORT": 8080
  });

if (!nconf.get("host")) {
  console.error("The host option is required for Plunker to start");
} else {
  
  //process.env.NODE_ENV = "production";

  var host = nconf.get("host");

  // Configure global paths
  if (nconf.get("nosubdomains")) {
    nconf.set("url:www", "http://" + host);
    nconf.set("url:raw", "http://" + host + "/raw");
    nconf.set("url:run", "http://" + host + "/run");
    nconf.set("url:api", "http://" + host + "/api");
    nconf.set("url:embed", "http://" + host + "/embed");
  } else {
    nconf.set("url:www", "http://" + host);
    nconf.set("url:raw", "http://raw." + host);
    nconf.set("url:run", "http://run." + host);
    nconf.set("url:api", "http://api." + host);
    nconf.set("url:embed", "http://embed." + host);  }
  
  // Create and start the parent server
  require("./index").listen(nconf.get("PORT"));
  
  console.log("Started plunker-www in", nconf.get("NODE_ENV") || "development", "at", nconf.get("host"), "on port", nconf.get("PORT"), "using subdomains:", !nconf.get("nosubdomains"));
}
