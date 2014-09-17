var Angular = require("angular");

module.exports =
Angular.module("plunker.services.api", [
  require("plunker.services.visitor").name,
])

.factory("api", ["$http", "config", "visitor", function ($http, config, visitor) {
  var api = {
    delete: function (path, query) {
      if (!query) query = {};
      
      return $http.delete(config.url.api + (path || "/"), {
        headers: { 'Authorization': "Bearer " + visitor.jwt },
        params: query,
      });
    },
    get: function (path, query) {
      if (!query) query = {};
      
      return $http.get(config.url.api + (path || "/"), {
        headers: { 'Authorization': "Bearer " + visitor.jwt, 'Accept': "application/json" },
        params: query,
      })
        .then(function (resp) {
          var data = resp.data;
          
          if (data.results && data.meta) {
            data = resp.data.results;
            data.meta = resp.data.meta;
          }
          
          return data;
        });
    },
    post: function (path, query, payload) {
      if (!query) query = {};
      
      return $http.post(config.url.api + (path || "/"), payload, {
        headers: { 'Authorization': "Bearer " + visitor.jwt },
        params: query,
      });
    },
  };
  
  return api;
}])

;