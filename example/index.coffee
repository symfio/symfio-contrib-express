symfio = require "symfio"


module.exports = container = symfio "example", __dirname

container.injectAll [
  require "symfio-contrib-winston"
  require ".."

  (get) ->
    get "/ping", ->
      (req, res) ->
        res.send "pong"
]


if require.main is module
  container.get("listener").then (listener) ->
    listener.listen()
