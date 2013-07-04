methods = require "methods"
http = require "http"


module.exports = (container) ->
  container.unless "port", 3000

  container.unless "middlewares", (env, logger, express) ->
    middlewares = []

    logger.debug "use express middleware", name: "bodyParser"
    middlewares.push express.bodyParser()

    logger.debug "use express middleware", name: "logger"
    middlewares.push express.logger "symfio"

    if env is "development"
      logger.debug "use express middleware", name: "errorHandler"
      middlewares.push express.errorHandler()

    middlewares

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

  container.set "app", (env, middlewares, express) ->
    app = express()
    app.set "env", env
    app.use middleware for middleware in middlewares
    app

  container.set "server", (app) ->
    http.createServer app

  container.set "listener", (logger, server, port) ->
    listen: ->
      server.listen port, ->
        logger.info "listen port", port: port

  methods.forEach (method) ->
    container.set method, (app, logger) ->
      ->
        argumentsArray = Array::slice.call arguments
        factory = argumentsArray.pop()

        logger.debug "define controller", method: method, url: arguments[0]

        container.inject(factory).then (controller) ->
          argumentsArray.push controller
          app[method].apply app, argumentsArray
