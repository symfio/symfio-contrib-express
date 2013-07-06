methods = require "methods"
suite = require "symfio-suite"
http = require "http"


describe "contrib-express()", ->
  it = suite.plugin [
    require ".."
  ]

  describe "container.unless port", ->
    it "should be 3000 by default", (port) ->
      port.should.equal 3000

  describe "container.unless middlewares", ->
    it "should contain bodyParser", (middlewares) ->
      middlewares[0].name.should.equal "bodyParser"

    it "should contain logger", (middlewares) ->
      middlewares[1].name.should.equal "logger"

    it "should contain errorHandler in development environment", (container) ->
      container.set "env", "development"

      container.get("middlewares").then (middlewares) ->
        middlewares[2].name.should.equal "errorHandler"

  describe "container.set express", ->
    it "should define custom logger", (express, logger) ->
      tokens = null
      req = method: "GET", originalUrl: "/", _startTime: new Date
      res = statusCode: 404

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
    it "should set env from container", (container) ->
      container.set "env", "noop"

      container.get("app").then (app) ->
        app.get("env").should.equal "noop"

    it "should use middlewares", (container) ->
      container.set "middlewares", [
        -> "boo"
      ]

      container.get("app").then (app) ->
        app.stack.pop().handle().should.equal "boo"

  describe "container.set server", ->
    it "should wrap app", (app, server) ->
      server.should.be.instanceOf http.Server
      server.listeners("request").should.contain app

  describe "container.set listener", ->
    it "should call server.listen", (container) ->
      container.set "port", 80

      container.set "server", (sandbox) ->
        server = listen: sandbox.stub()
        server.listen.yields()
        server

      container.inject (listener, server) ->
        listener.listen()
        server.listen.should.be.calledOnce
        server.listen.should.be.calledWith 80

  methods.forEach (method) ->
    describe "container.set #{method}", ->
      it "should wrap app.#{method}", (container) ->
        container.set "app", (sinon) ->
          app = {}
          app[method] = sinon.spy()
          app

        container.get([method, "app"]).spread (controller, app) ->
          controller "/", (port) ->
            (req, res) ->
              port
          .then ->
            app[method].should.be.calledOnce
            app[method].should.be.calledWith "/"
            app[method].lastCall.args[1]().should.equal 3000
