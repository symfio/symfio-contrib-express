express = require "express"
methods = require "methods"
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

  methods.forEach (method) ->
    container.set method, (app) ->
      ->
        argumentsArray = Array::slice.call arguments
        factory = argumentsArray.pop()

        container.call(factory).then (controller) ->
          argumentsArray.push controller
          app[method].apply app, argumentsArray

  if autoload
    container.on "loaded", ->
      container.call (server, port) ->
        server.listen port

  container.call (logger, express, app) ->
    if logger
      express.logger.format "symfio", (tokens, req, res) ->
        logger.info "incoming http request",
          method: req.method
          url: req.originalUrl
          status: res.statusCode
          time: new Date - req._startTime

      app.use express.logger "symfio"
