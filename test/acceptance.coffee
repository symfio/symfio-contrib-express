suite = require "symfio-suite"


describe "contrib-express example", ->
  wrapper = suite.http require "../example"

  describe "GET /ping", ->
    it "should respond with pong", wrapper (callback) ->
      test = @http.get "/ping"
      test.res (res) =>
        @expect(res).to.have.status 200
        @expect(res.text).to.equal "pong"
        callback()
