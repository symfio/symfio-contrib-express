methods = require "methods"
symfio = require "symfio"
sinon = require "sinon"
chai = require "chai"
http = require "http"


describe "contrib-express()", ->
  chai.use require "chai-as-promised"
  chai.use require "sinon-chai"
  chai.should()

  container = null
  sandbox = null

  beforeEach (callback) ->
    container = symfio "test", __dirname
    sandbox = sinon.sandbox.create()

    container.set "logger", ->
      debug: sandbox.spy()
      info: sandbox.spy()

    container.injectAll([
      require ".."
    ]).should.notify callback

  afterEach ->
    sandbox.restore()

  describe "container.unless port", ->
    it "should be 3000 by default", (callback) ->
      container.inject (port) ->
        port.should.equal 3000
      .should.notify callback

  describe "container.unless middlewares", ->
    it "should contain bodyParser", (callback) ->
      container.inject (middlewares) ->
        middlewares[0].name.should.equal "bodyParser"
      .should.notify callback

    it "should contain logger", (callback) ->
      container.inject (middlewares) ->
        middlewares[1].name.should.equal "logger"
      .should.notify callback

    it "should contain errorHandler in development environment", (callback) ->
      container.inject (middlewares) ->
        middlewares[2].name.should.equal "errorHandler"
      .should.notify callback

  describe "container.set express", ->
    it "should define custom logger", (callback) ->
      tokens = null
      req = method: "GET", originalUrl: "/", _startTime: new Date
      res = statusCode: 404

      container.inject (express) ->
        express.logger.should.have.property "symfio"
        express.logger.symfio.should.be.a "function"
        express.logger.symfio tokens, req, res
      .then ->
        container.get "logger"
      .then (logger) ->
        logger.info.should.be.calledOnce
        logger.info.lastCall.args[0].should.equal "incoming http request"
        logger.info.lastCall.args[1].method.should.equal "GET"
        logger.info.lastCall.args[1].url.should.equal "/"
        logger.info.lastCall.args[1].status.should.equal 404
        logger.info.lastCall.args[1].time.should.be.a "number"
      .should.notify callback

  describe "container.set app", ->
    it "should set env from container", (callback) ->
      container.set "env", "noop"

      container.inject (app) ->
        app.get("env").should.equal "noop"
      .should.notify callback

    it "should use middlewares", (callback) ->
      container.set "middlewares", [
        -> "boo"
      ]

      container.inject (app) ->
        app.stack.pop().handle().should.equal "boo"
      .should.notify callback

  describe "container.set server", ->
    it "should wrap app", (callback) ->
      container.inject (app, server) ->
        server.should.be.instanceOf http.Server
        server.listeners("request").should.contain app
      .should.notify callback

  describe "container.set listener", ->
    it "should call server.listen", (callback) ->
      container.set "port", 80
      container.set "server", ->
        server = listen: sandbox.stub()
        server.listen.yields()
        server

      container.inject (listener) ->
        listener.listen()
      .then ->
        container.get "server"
      .then (server) ->
        server.listen.should.be.calledOnce
        server.listen.should.be.calledWith 80
      .should.notify callback

  methods.forEach (method) ->
    describe "container.set #{method}", ->
      it "should wrap app.#{method}", (callback) ->
        container.set "app", ->
          app = {}
          app[method] = sinon.spy()
          app

        container.get(method).then (controller) ->
          controller "/", (port) ->
            (req, res) ->
              port
        .then ->
          container.get "app"
        .then (app) ->
          app[method].should.be.calledOnce
          app[method].should.be.calledWith "/"
          app[method].lastCall.args[1]().should.equal 3000
        .should.notify callback
