var Boom = require("boom");
var Joi = require("joi");
var Pad = require("padded-semver");
var _ = require("lodash");

var internals = {};

internals.validPlunkId = Joi.string().regex(/^[a-zA-Z0-9]+$/);


exports.fetch = function (db, plunkId, options) {
  return db.getPlunk(plunkId)
    .then(function (plunk) {
      if (plunk.deleted_at) throw new Boom.resourceGone("Project is already deleted.");
      
      //if (options.incrementViews) return internals.update(plunk, {views_count: plunk.views_count + 1});
      
      return plunk;
    });
};


exports.prepare = function (json) {
  json = _.clone(json);
  
  _.forEach(json.packages, function (pkg) {
    try {
      pkg.semver = Pad.unpad(pkg.semver);
    } catch (e) {
      console.log("[WARN] Invalid padded semver", pkg.semver);
      pkg.semver = pkg.semver;
    }
  });
  
  return json;
};

exports.handleLookup = {
  validate: {
    params: {
      plunkId: internals.validPlunkId.required(),
    },
  },
  handler: function (request, reply) {
    exports.fetch(this.db, request.params.plunkId, { incrementViews: true, readonly: true })
      .then(exports.prepare)
      //.then(internals.joinUsersToPlunk)
      .then(reply, reply);
  }
};
