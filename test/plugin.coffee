methods = require "methods"
suite = require "symfio-suite"


describe "contrib-express()", ->
  it = suite.plugin (container) ->
    container.inject ["suite/container"], require ".."

    container.set "middlewares", []
    container.set "port", 80

    container.set "app", (sandbox) ->
      app = sandbox.spy()
      app.set = sandbox.spy()
      app.use = sandbox.spy()
      methods.forEach (method) ->
        app[method] = sandbox.spy()
      app

    container.set "http", (sandbox) ->
      createServer: sandbox.stub()

    container.set "express", (app, sandbox) ->
      express = sandbox.stub()
      express.bodyParser = sandbox.spy()
      express.logger = sandbox.spy()
      express.errorHandler = sandbox.spy()
      express.returns app
      express

    container.set "server", (sandbox) ->
      server = listen: sandbox.stub()
      server.listen.yields()
      server

  describe "container.require http", ->
    it "should require", (required) ->
      required("http").should.equal "http"

  describe "container.unless port", ->
    it "should be 3000 by default", (unlessed) ->
      factory = unlessed "port"
      factory().should.eventually.equal 3000

  describe "container.unless middlewares", ->
    it "should contain bodyParser", (unlessed, express) ->
      factory = unlessed "middlewares"
      factory().then ->
        express.bodyParser.should.be.calledOnce

    it "should contain logger", (unlessed, express) ->
      factory = unlessed "middlewares"
      factory().then ->
        express.logger.should.be.calledOnce

    it "should contain errorHandler in development environment",
      (unlessed, express) ->
        factory = unlessed "middlewares"
        factory.dependencies.env = "development"
        factory().then ->
          express.errorHandler.should.be.calledOnce

  describe "container.set express", ->
    # speedup test
    require "express"

    it "should define custom logger", (setted, logger) ->
      tokens = null
      req = method: "GET", originalUrl: "/", _startTime: new Date
      res = statusCode: 404

      factory = setted "express"
      factory().then (express) ->
        express.logger.should.have.property "symfio"
        express.logger.symfio.should.be.a "function"
        express.logger.symfio tokens, req, res

        logger.info.should.be.calledOnce
        logger.info.lastCall.args[0].should.equal "incoming http request"
        logger.info.lastCall.args[1].method.should.equal "GET"
        logger.info.lastCall.args[1].url.should.equal "/"
        logger.info.lastCall.args[1].status.should.equal 404
        logger.info.lastCall.args[1].time.should.be.a "number"

  describe "container.set app", ->
    it "should set env from container", (setted, app, env) ->
      factory = setted "app"
      factory().then ->
        app.set.should.be.calledOnce
        app.set.should.be.calledWith "env", env

    it "should use middlewares", (setted, app) ->
      factory = setted "app"
      factory.dependencies.middlewares = ["middleware"]
      factory().then ->
        app.use.should.be.calledOnce
        app.use.should.be.calledWith "middleware"

  describe "container.set server", ->
    it "should wrap app", (setted, http, app) ->
      factory = setted "server"
      factory().then ->
        http.createServer.should.be.calledOnce
        http.createServer.should.be.calledWith app

  methods.forEach (method) ->
    describe "container.set #{method}", ->
      it "should wrap app.#{method}",
        ["setted", "suite/container", "app"],
        (setted, container, app) ->
          factory = setted method
          factory.dependencies.container = container
          factory().then (controller) ->
            controller "/", "factory"
            container.inject.promise.then.yield()
            app[method].should.be.calledOnce
            app[method].should.be.calledWith "/"
            container.inject.should.calledOnce
            container.inject.should.calledWith "factory"

  describe "container.set startExpressServer", ->
    it "should call server.listen", (setted, server, port) ->
      factory = setted "startExpressServer"
      factory().then (startExpressServer) ->
        startExpressServer()
        server.listen.should.be.calledOnce
        server.listen.should.be.calledWith port
