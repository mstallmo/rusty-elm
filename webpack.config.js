const path = require("path");
const HtmlWebpackPlugin = require("html-webpack-plugin");
const WasmPackPlugin = require("@wasm-tool/wasm-pack-plugin/plugin");
const dist = path.resolve(__dirname, "dist");
const webpack = require("webpack");
require("dotenv").config();

const IS_PRODUCTION = process.env.NODE_ENV === 'production';

module.exports = {
  entry: "./js/bootstrap.js",
  mode: (IS_PRODUCTION) ? 'production' : 'development',
  output: {
    path: dist,
    filename: "bundle.js"
  },
  devServer: {
    contentBase: dist,
    headers: {
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, PATCH, OPTIONS",
      "Access-Control-Allow-Headers": "X-Requested-With, content-type, Authorization"
    }
  },
  plugins: [
    new HtmlWebpackPlugin({
      template: './static/index.html'
    }),

    new WasmPackPlugin({
      crateDirectory: path.resolve(__dirname, "crate"),
      // WasmPackPlugin defaults to compiling in "dev" profile. To change that, use forceMode: 'release':
      forceMode: (IS_PRODUCTION) ? 'release' : ''
    }),

    new webpack.EnvironmentPlugin(["API_URL"])
  ],
  module: {
    rules: [
      {
        test: /\.elm$/,
        exclude: [/elm-stuff/, /node-modules/],
        loader: 'elm-webpack-loader',
        options: {
          debug: false,
          optimize: IS_PRODUCTION
        }
      }
    ]
  }
};
