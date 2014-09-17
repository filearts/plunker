var NgAnnotatePlugin = require("ng-annotate-webpack-plugin");
var Path = require("path");
var Webpack = require("webpack");

module.exports = function (config) {
  return {
    cache: true,
    entry: {
      plunker: [__dirname + "/src/apps/plunker.js"],
    },
    output: {
      path: Path.join(__dirname, "static", "build"),
      filename: "[name].js",
      publicPath: "/static/",
    },
    module: {
      loaders: [
        { test: /[\/\\]ace\.js$/, loader: "exports-loader?window.ace" },
        { test: /[\/\\]angular\.js$/, loader: "exports-loader?window.angular" },
        { test: /[\/\\]angular-animate\.js$/, loader: "ng-loader?ngAnimate" },
        { test: /[\/\\]angular-cookie\.js$/, loader: "ng-loader?ipCookie" },
        { test: /[\/\\]angular-ui-router\.js$/, loader: "ng-loader?ui.router" },
        { test: /[\/\\]detect-element-resize\.js$/, loader: "exports-loader?addResizeListener=window.addResizeListener,removeResizeListener=window.removeResizeListener" },
        { test: /[\/\\]timeAgo\.js$/, loader: "ng-loader?yaru22.angular-timeago" },
        { test: /[\/\\]ui-bootstrap-tpls\.js$/, loader: "ng-loader?ui.bootstrap" },
        { test: /\.css$/,   loader: "style-loader!css-loader" },
        { test: /\.less$/,  loader: "style-loader!css-loader!less-loader" },
        { test: /\.woff$/,  loader: "url-loader?limit=10000&mimetype=application/font-woff" },
        { test: /\.ttf$/,   loader: "file-loader" },
        { test: /\.eot$/,   loader: "file-loader" },
        { test: /\.svg$/,   loader: "file-loader" },
        { test: /\.html$/,  loader: "raw-loader" },
        { test: /\.json$/,  loader: "json-loader" },
      ],
      noParse: [
        /[\/\\]ace\.js$/,
        /[\/\\]angular\.js$/,
        /[\/\\]angular-animate\.js$/,
        /[\/\\]angular-cookie\.js$/,
        /[\/\\]angular-ui-router\.js$/,
        /[\/\\]detect-element-resize\.js$/,
        /[\/\\]timeAgo\.js$/,
        /[\/\\]ui-bootstrap-tpls\.js$/,
      ]
    },
    plugins: [
      new PlunkerModuleReplacementPlugin(),
      new Webpack.DefinePlugin({
        CONFIG: JSON.stringify(config)
      }),
      // new Webpack.optimize.DedupePlugin(),
      // new NgAnnotatePlugin(),
      // new Webpack.optimize.UglifyJsPlugin({
      //   mangle: false,
      //   compress: false,
      // }),
    ],
    resolve: {
      modulesDirectories: ["node_modules", "bower_components", "src"],
      root: __dirname,
      alias: {
        'ace': "ace-builds/src-noconflict/ace.js",
        'angular': "angular/angular.js",
        'angular-animate': "angular-animate/angular-animate.js",
        'angular-cookie': "angular-cookie/angular-cookie.js",
        'angular-timeago': "angular-timeago/src/timeAgo.js",
        'angular-ui-router': "angular-ui-router/release/angular-ui-router.js",
        'angular-ui-bootstrap': "angular-bootstrap/ui-bootstrap-tpls.js",
        'on-resize': "javascript-detect-element-resize/detect-element-resize.js",
      },
    },
  };
};



function PlunkerModuleReplacementPlugin () {
  this.resourceRegExp = /^plunker(?:\.(\w+))+$/;
}
PlunkerModuleReplacementPlugin.prototype.apply = function (compiler) {
  var resourceRegExp = this.resourceRegExp;
  compiler.plugin("normal-module-factory", function (nmf) {
    nmf.plugin("before-resolve", function (result, callback) {
      if (!result) return callback();
      
      if (resourceRegExp.test(result.request)) {
        var parts = result.request.split(".").slice(1);
        
        result.request = parts.join("/");
      }

      return callback(null, result);
    });
  });
};