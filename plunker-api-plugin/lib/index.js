var Routes = require("./routes");


var Db = require("./database");



exports.register = function (plugin, options, next) {
  
  var db = new Db(plugin.app.config.database);
  
  plugin.bind({
    config: options.config,
    db: db,
  });
  
  plugin.route(Routes.endpoints);
  
  next();
};

exports.register.attributes = {
  pkg: require('../package.json')
};

