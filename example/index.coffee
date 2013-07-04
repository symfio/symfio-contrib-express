symfio = require "symfio"


module.exports = container = symfio "example", __dirname

container.use require "symfio-contrib-winston"
container.use require ".."

container.use (get) ->
  get "/ping", ->
    (req, res) ->
      res.send "pong"

container.load() if require.main is module
