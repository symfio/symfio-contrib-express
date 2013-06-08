express = require "express"
http = require "http"


module.exports = (container, autoload = true, port = 3000) ->
  container.set "port", port

  container.set "express", ->
    express

  container.set "app", (express) ->
    app = express()

    app.configure ->
      app.use express.bodyParser()

    app.configure "development", ->
      app.use express.errorHandler()

    app

  container.set "server", (app) ->
    http.createServer app

  if autoload
    container.on "loaded", ->
      container.call (server, port) ->
        server.listen port
