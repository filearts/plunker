var Boom = require("boom");
var Collections = require("./collections");
var Objects = require("./objects");
var Plunks = require("./plunks");

exports.endpoints = [

  { method: 'GET', path: '/search/{collection*2}', config: Collections.handleSearch },

  { method: 'GET', path: '/objects/{sha}', config: Objects.handleLookup },

  { method: 'GET', path: '/plunks/{plunkId}', config: Plunks.handleLookup },

  { method: '*', path: '/{any*}', handler: function (request, reply) { reply(Boom.notFound()); } },
];