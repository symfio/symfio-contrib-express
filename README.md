# symfio-contrib-express

> Launch express application after all plugins is loaded.

[![Build Status](http://teamcity.rithis.com/httpAuth/app/rest/builds/buildType:id:bt8,branch:master/statusIcon?guest=1)](http://teamcity.rithis.com/viewType.html?buildTypeId=bt8&guest=1)
[![Dependency Status](https://gemnasium.com/symfio/symfio-contrib-express.png)](https://gemnasium.com/symfio/symfio-contrib-express)

## Usage

```coffee
symfio = require "symfio"

container = symfio "example", __dirname
container.set "port", 80

loader = container.get "loader"

loader.use require "symfio-contrib-express"

loader.use (container, callback) ->
  app = container.get "app"

  app.get "/", (req, res) ->
    res.send "Hello World!"

loader.load()
```

## Provides

* __app__ — Express application.
* __server__ — `http.Server` instance for express application.
* __express__ — Original express module.

## Can be configured

* __port__ - Port for listening. Default value received from `process.env.PORT`.
  If `process.env.PORT` is undefined then default value is `3000`.
