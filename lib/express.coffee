methods = require "methods"
http = require "http"


module.exports = (container, autoload = true) ->
  container.unless "port", 3000

  container.set "express", (logger) ->
    logger.debug "require module", name: "express"

    express = require "express"

    express.logger.format "symfio", (tokens, req, res) ->
      logger.info "incoming http request",
        method: req.method
        url: req.originalUrl
        status: res.statusCode
        time: new Date - req._startTime

    express

  container.set "app", (env, logger, express) ->
    app = express()

    app.set "env", env

    app.configure ->
      logger.debug "use express middleware", name: "bodyParser"
      app.use express.bodyParser()
      logger.debug "use express middleware", name: "logger"
      app.use express.logger "symfio"

    app.configure "development", ->
      logger.debug "use express middleware", name: "errorHandler"
      app.use express.errorHandler()

    app

  container.set "server", (app) ->
    http.createServer app

  methods.forEach (method) ->
    container.set method, (app, logger) ->
      ->
        argumentsArray = Array::slice.call arguments
        factory = argumentsArray.pop()

        logger.debug "define controller", method: method, url: arguments[0]

        container.call(factory).then (controller) ->
          argumentsArray.push controller
          app[method].apply app, argumentsArray

  if autoload
    container.on "loaded", ->
      container.call (logger, server, port) ->
        server.listen port, ->
          logger.info "listen port", port: port
