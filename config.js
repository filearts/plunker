module.exports = {
  server: {
    api: {
      host: process.env.IP || "0.0.0.0",
      port: process.env.PORT || 8081,
    },
    web: {
      host: "0.0.0.0",
      port: 8080,
    },
  },
  database: {
    elasticsearch: {
      url: process.env.ES_URL || "127.0.0.1:9200",
    },
  },
  auth: {
    secret: process.env.PLUNKER_SECRET || "Plunker development secret",
  },
  shared: {
    url: {
      api: "http://explore.plunker.co:8080/api",
      run: "http://run.plnkr.co",
      shot: "http://shot.plunker.co",
      web: "http://explore.plunker.co",
    },
  },
};