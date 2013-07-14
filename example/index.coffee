symfio = require "symfio"


module.exports = container = symfio "example", __dirname

module.exports.promise = container.injectAll [
  require "symfio-contrib-winston"
  require ".."

  (get) ->
    get "/ping", ->
      (req, res) ->
        res.send "pong"
]


if require.main is module
  module.exports.promise.then ->
    container.get "startExpressServer"
  .then (startExpressServer) ->
    startExpressServer()
