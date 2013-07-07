methods = require "methods"
suite = require "symfio-suite"
http = require "http"


describe "contrib-express()", ->
  it = suite.plugin (container, containerStub) ->
    require("..") containerStub

    container.set "app", (sandbox) ->
      app = sandbox.spy()
      app.set = sandbox.spy()
      app.use = sandbox.spy()
      methods.forEach (method) ->
        app[method] = sandbox.spy()
      app

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

  describe "container.unless port", ->
    it "should be 3000 by default", (containerStub) ->
      containerStub.unless.get("port").should.equal 3000

  describe "container.unless middlewares", ->
    it "should contain bodyParser", (containerStub, env, logger, express) ->
      factory = containerStub.unless.get "middlewares"
      factory env, logger, express
      express.bodyParser.should.be.calledOnce

    it "should contain logger", (containerStub, env, logger, express) ->
      factory = containerStub.unless.get "middlewares"
      factory env, logger, express
      express.logger.should.be.calledOnce

    it "should contain errorHandler in development environment",
      (containerStub, env, logger, express) ->
        factory = containerStub.unless.get "middlewares"
        factory env, logger, express
        express.errorHandler.should.not.be.called
        factory "development", logger, express
        express.errorHandler.should.be.calledOnce

  describe "container.set express", ->
    # speedup test
    require "express"

    it "should define custom logger", (containerStub, logger) ->
      tokens = null
      req = method: "GET", originalUrl: "/", _startTime: new Date
      res = statusCode: 404

      factory = containerStub.set.get "express"
      express = factory logger

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
    it "should set env from container", (containerStub, env, express, app) ->
      factory = containerStub.set.get "app"
      factory env, [], express
      app.set.should.be.calledOnce
      app.set.should.be.calledWith "env", env

    it "should use middlewares", (containerStub, env, express, app) ->
      factory = containerStub.set.get "app"
      factory env, ["middleware"], express
      app.use.should.be.calledOnce
      app.use.should.be.calledWith "middleware"

  describe "container.set server", ->
    it "should wrap app", (containerStub, app) ->
      factory = containerStub.set.get "server"
      server = factory app
      server.should.be.instanceOf http.Server
      server.listeners("request").should.contain app

  describe "container.set listener", ->
    it "should call server.listen", (containerStub, logger, server) ->
      factory = containerStub.set.get "listener"
      listener = factory logger, server, 80
      listener.listen()
      server.listen.should.be.calledOnce
      server.listen.should.be.calledWith 80

  methods.forEach (method) ->
    describe "container.set #{method}", ->
      it "should wrap app.#{method}", (containerStub, app, logger) ->
        factory = containerStub.set.get method
        controller = factory app, logger, containerStub

        controller "/", "factory"
        containerStub.inject.promise.then.yield()
        app[method].should.be.calledOnce
        app[method].should.be.calledWith "/"
        containerStub.inject.should.calledOnce
        containerStub.inject.should.calledWith "factory"
