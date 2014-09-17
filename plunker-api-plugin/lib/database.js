var Elastic = require("elastic.js");
var Elasticsearch = require("elasticsearch");
var Promise = require("bluebird");
var _ = require("lodash");


var internals = {};

module.exports = internals.Database = function Database (options) {
  this.es = new Elasticsearch.Client({
    host: options.elasticsearch.url,
  });
};

internals.Database.prototype.findPlunks = function (collection, options) {
  var filter = Elastic.AndFilter(Elastic.TermFilter("collections", collection));
  var query = Elastic.Request()
    .query(Elastic.FilteredQuery(Elastic.MatchAllQuery(), filter))
    .sort("updated_at", "desc");

  if (options.q) {
    query = Elastic.Request()
      .query(Elastic.FilteredQuery(
        Elastic.BoolQuery()
          .should(Elastic.MatchQuery("_all", options.q))
          .should(Elastic.MatchQuery("title", options.q).boost(3))
          .should(Elastic.MatchQuery("readme", options.q).boost(2)),
        filter
      ))
      .sort("_score", "desc");
  }
  
  
  if (options.tags) {
    _.forEach(options.tags, function (tag) {
      filter.filters(Elastic.TermFilter("tags", tag.toLowerCase()));
    });
  }
  
  if (options.packages) {
    _.forEach(options.packages, function (pkg) {
      filter.filters(Elastic.TermFilter("packages.name", pkg.toLowerCase()));
    });
  }
  
  query
    .aggregation(Elastic.TermsAggregation("tags").field("tags").size(5))
    .aggregation(Elastic.TermsAggregation("packages").field("packages.name").size(5));
    
  return this.es.search({
    index: "plunker",
    type: "plunk",
    body: query.toJSON(),
  }).then(function (body, resp) {
    var plunks = _.pluck(body.hits.hits, "_source");
    var promise = Promise.resolve(plunks);
    
    return _.reduce(options.mappers, function (result, mapper) {
      return result.map(mapper);
    }, promise)
      .then(function (plunks) {
        return{
          meta: {
            count: body.hits.total,
            skip: options.skip,
            limit: options.limit,
            facets: _(body.aggregations).mapValues(function (facet, name) {
              return _.map(facet.buckets, function (bucket) {
                return { term: bucket.key, count: bucket.doc_count};
              });
            }).value()
          },
          results: plunks,
        };
      });
  });
};

internals.Database.prototype.getPlunk = function (plunkId) {
  return this.es.getSource({
    index: "plunker",
    type: "plunk",
    id: plunkId,
  });
};