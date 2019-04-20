const path = require("path");
const HtmlWebpackPlugin = require("html-webpack-plugin");
const WasmPackPlugin = require("@wasm-tool/wasm-pack-plugin/plugin");
const dist = path.resolve(__dirname, "dist");

module.exports = {
  entry: "./js/index.js",
  mode: 'development',
  output: {
    path: dist,
    filename: "bundle.js"
  },
  devServer: {
    contentBase: dist,
  },
  plugins: [
    new HtmlWebpackPlugin({
      template: 'index.html'
    }),

    new WasmPackPlugin({
      crateDirectory: path.resolve(__dirname, "crate"),
      // WasmPackPlugin defaults to compiling in "dev" profile. To change that, use forceMode: 'release':
      // forceMode: 'release'
    }),
  ],
  module: {
    rules: [
      {
        test: /\.elm$/,
        exclude: [/elm-stuff/, /node-modules/],
        loader: 'elm-webpack-loader',
        options: {
          debug: true
        }
      }
    ]
  }
};
