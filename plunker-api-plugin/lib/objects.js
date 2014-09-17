var Bops = require("bops");
var Joi = require("joi");
var _ = require("lodash");

exports.fetch = function (db, sha) {
  return db.fetchObject(sha)
    .then(function (buf) {
      var loose_type;
      var body_start = 0;
      var idx = 0;
      var len = buf.length;
      
      while (idx < len) {
        if (buf[idx] === 20) {
          loose_type = Bops.to(Bops.subarray(buf, 0, idx - 1), "utf8"); 
        } else if (buf[idx] === 0) {
          body_start = idx + 1;
          break;
        }
      }
      
      return {
        type: loose_type,
        buf: Bops.subarray(body_start, buf.length),
      };
    });
};


exports.handleLookup = {
  auth: false,
  validate: {
    params: {
      sha: Joi.string().alphanum().length(40).required(),
    }
  },
  handler: function (request, reply) {
    exports.fetch(this.db, request.params.sha)
      .then(reply, reply);
  },
};