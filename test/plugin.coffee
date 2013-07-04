plugin = require ".."
symfio = require "symfio"
chai = require "chai"


describe "contrib-express plugin", ->
  chai.use require "chai-as-promised"
  chai.should()

  container = symfio "example", __dirname

  before (callback) ->
    container.set "autoload", false
    container.use plugin
    container.load().should.notify callback

  it "should use bodyParser", (callback) ->
    container.get("app").then (app) ->
      app.stack[2].handle.name.should.equal "bodyParser"
    .should.notify callback

  it "should use logger", (callback) ->
    container.get("app").then (app) ->
      app.stack[3].handle.name.should.equal "logger"
    .should.notify callback

  it "should use errorHandler in development environment", (callback) ->
    container.get("app").then (app) ->
      app.stack[4].handle.name.should.equal "errorHandler"
    .should.notify callback
