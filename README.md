# symfio-contrib-express

> Express plugin for Symfio.

[![Build Status](http://teamcity.rithis.com/httpAuth/app/rest/builds/buildType:id:bt8,branch:master/statusIcon?guest=1)](http://teamcity.rithis.com/viewType.html?buildTypeId=bt8&guest=1)
[![Dependency Status](https://gemnasium.com/symfio/symfio-contrib-express.png)](https://gemnasium.com/symfio/symfio-contrib-express)

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
