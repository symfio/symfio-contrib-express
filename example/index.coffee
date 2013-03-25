symfio = require "symfio"

module.exports = container = symfio "example", __dirname
loader = container.get "loader"

loader.use require "../lib/express"

loader.use (container, callback) ->
  app = container.get "app"

  app.get "/ping", (req, res) ->
    res.send "pong"

  callback()

loader.load() if require.main is module
