suite = require "symfio-suite"


describe "contrib-express example", ->
  it = suite.example require "../example"

  describe "GET /ping", ->
    it "should respond with pong", (request) ->
      request.get("/ping").then (res) ->
        res.should.have.status 200
        res.text.should.equal "pong"
