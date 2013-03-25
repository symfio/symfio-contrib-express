express = require "express"
symfio = require "symfio"
plugin = require "../lib/express"
suite = require "symfio-suite"


describe "contrib-express plugin", ->
  wrapper = suite.sandbox symfio, ->
    @sandbox.stub express.application, "use"
    @use = express.application.use

  it "should use bodyParser", wrapper ->
    @sandbox.stub express.application, "defaultConfiguration"

    plugin @container, ->

    @expect(@use).to.have.been.calledOnce
    @expect(@use.lastCall.args[0].name).to.equal "bodyParser"

  it "should use errorHandler in development environment", wrapper ->
    nodeEnv = process.env.NODE_ENV
    process.env.NODE_ENV = "development"

    plugin @container, ->

    @expect(@use.lastCall.args[0].name).to.equal "errorHandler"

    process.env.NODE_ENV = nodeEnv
