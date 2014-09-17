var Joi = require("joi");
var Plunks = require("./plunks");
var _ = require("lodash");


exports.handleSearch = {
  auth: false,
  validate: {
    query: {
      q: Joi.string().allow("").optional().default(""),
      tags: Joi.alternatives().try(
        Joi.string().optional().allow(null),
        Joi.array().optional().allow([]).includes(Joi.string())
      ).optional().default([]),
      packages: Joi.alternatives().try(
        Joi.string().optional().allow(null),
        Joi.array().optional().allow([]).includes(Joi.string())
      ).optional().default([]),
      limit: Joi.number().optional().default(9),
      skip: Joi.number().optional().default(0),
    }
  },
  handler: function (request, reply) {
    if (_.isString(request.query.tags)) request.query.tags = [request.query.tags];
    if (_.isString(request.query.packages)) request.query.packages = [request.query.packages];
    
    var options = _.extend(request.query, {
      mappers: [Plunks.prepare],
    });
    
    this.db.findPlunks(request.params.collection, options)
      .then(reply, reply);
  },
};