chai = require "chai"
w = require "when"


describe "contrib-express example", ->
  chai.use require "chai-as-promised"
  chai.use require "chai-http"
  chai.should()

  container = require "../example"

  before (callback) ->
    container.set "autoload", false
    container.load().should.notify callback

  describe "GET /ping", ->
    it "should respond with pong", (callback) ->
      container.get("app").then (app) ->
        deferred = w.defer()
        chai.request(app).get("/ping").res deferred.resolve
        deferred.promise
      .then (res) ->
        res.should.have.status 200
        res.text.should.equal "pong"
      .should.notify callback
