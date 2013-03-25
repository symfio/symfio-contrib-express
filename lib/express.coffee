express = require "express"
http = require "http"


module.exports = (container, callback) ->
  unloader = container.get "unloader"
  loader = container.get "loader"
  logger = container.get "logger"
  port = container.get "port", process.env.PORT or 3000

  logger.info "loading plugin", "contrib-express"

  app = express()

  app.use express.bodyParser()

  app.configure "development", ->
    app.use express.errorHandler()

  server = http.createServer app

  container.set "app", app
  container.set "server", server
  container.set "express", express

  loader.once "loaded", ->
    server.listen port, ->
      logger.info "listening", port, "express"

  unloader.register (callback) ->
    server.close callback

  callback()
