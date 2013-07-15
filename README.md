# symfio-contrib-express

> Express plugin for Symfio.

[![Build Status](https://travis-ci.org/symfio/symfio-contrib-express.png?branch=master)](https://travis-ci.org/symfio/symfio-contrib-express)
[![Coverage Status](https://coveralls.io/repos/symfio/symfio-contrib-express/badge.png?branch=master)](https://coveralls.io/r/symfio/symfio-contrib-express?branch=master)
[![Dependency Status](https://gemnasium.com/symfio/symfio-contrib-express.png)](https://gemnasium.com/symfio/symfio-contrib-express)
[![NPM version](https://badge.fury.io/js/symfio-contrib-express.png)](http://badge.fury.io/js/symfio-contrib-express)

## Usage

```coffee
symfio = require "symfio"

container = symfio "example", __dirname

container.set "port", 80

container.inject require "symfio-contrib-express"

container.inject (get) ->
  get "/", ->
    (req, res) ->
      res.send "Hello World!"
```

## Configuration

### `port`

Port for listening. Default value is `3000`.

### `middlewares`

Application middlewares.

## Services

### `express`

Original express module.

### `app`

Express application.

### `server`

`http.Server` instance for express application.

### `startExpressServer`

Function used to start server after all plugins is loaded.

### `get`, `post`, `put`, `delete`, `patch`, etc.

Working like original `app` methods, but last argument must be controller
factory.
